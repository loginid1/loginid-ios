//
//  MFA.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDAPIClient

/// Provides the core interface for performing Multi-Factor Authentication (MFA) flows.
///
/// Handles MFA configuration, secure session storage, device trust management, and persistence
/// of MFA-related data.
final class MFA : Sendable {
    private let trustId: TrustIDManaging
    private let session: SessionManaging
    private let config: LoginIDConfig
    private let store: MFAStoring
    
    /**
     Creates a new MFA instance.
     
     - Parameters:
       - config: The `LoginIDConfig` containing API configuration values.
       - store: An `MFAStoring` implementation for persisting MFA-related data such as device IDs.
       - session: A `SessionManaging` implementation for handling MFA session tokens.
       - trustId: A `TrustIDManaging` implementation for managing device trust identifiers.
     */
    public init(
        config: LoginIDConfig,
        store: MFAStoring,
        session: SessionManaging,
        trustId: TrustIDManaging
    ) {
        self.config = config
        self.store = store
        self.session = session
        self.trustId = trustId
    }
    
    /**
     Initiates the pre-authentication process for Multi-Factor Authentication (MFA).

     Begins an MFA session and persists session details to secure storage.

     Use `performAction` to continue the MFA flow with a required payload when needed.

     - Parameters:
       - username: The username of the user initiating MFA.
       - options: Optional parameters for initiating MFA. Pass `nil` to use defaults.
     - Returns: An `MFASessionResult` describing the current MFA session state and next actions.
     - Throws: `LoginIDError` if the request fails or the response is invalid.
     */
    public func beginFlow(
        username: String,
        options: BeginFlowOptions?
    ) async throws -> MFASessionResult {
        let deviceId = store.getDeviceId()
        let deviceInfo = await DeviceUtils.getDeviceInfo(deviceId: deviceId)
        let customUserAgent = await DeviceUtils.getUserAgent()
        let values = BeginFlowOptionDefaults(username: username, options: options)
        
        var walletTrustId: String? = nil
        if values.txPayload != nil {
            walletTrustId = try trustId.signWithTrustId()
        }
        
        let mfaBeginRequestBody = MfaBeginRequestBody(
            deviceInfo: deviceInfo,
            payload: values.txPayload,
            traceId: values.traceId,
            trustItems: [
                "wallet": walletTrustId ?? "",
                "merchant": values.checkoutId ?? "",
            ],
            user: values.user,
        )
        
        let mfaNextResult = try await MfaAPI.mfaMfaBegin(
            // Already supplied by device info
            userAgent: customUserAgent,
            mfaBeginRequestBody: mfaBeginRequestBody,
        )
        
        let info = MFAInfo(result: mfaNextResult, username: username)
        
        session.logout()
        store.storeMFAInfo(info)
        
        return MFASessionResult(info: info, tokenSet: nil)
    }
    
    /**
     Performs a Multi-Factor Authentication (MFA) action using the specified factor.

     Supports passkeys, OTP (email/SMS), and external authentication. Validates the
     provided options, processes the step, calls the corresponding MFA API, and updates
     the MFA session details upon success.

     - Important:
       - **Passkeys:** Uses WebAuthn for authentication or registration.
       - **External authentication:** Provide the authorization code in `options.payload`.
       - **OTP Request (email/SMS):** Sends an OTP to the user's contact. If `options.payload`
         contains a contact, it is used; otherwise, the primary contact on record is used.
       - **OTP Verify (email/SMS):** Verifies the OTP code provided in `options.payload`.

     - Parameters:
       - action: The MFA factor to perform (e.g., `.passkeyAuth`,  `.passkeyReg`, `.passkeyTx`, `.external`).
       - options: The session/payload options for the action. Pass `nil` to resolve defaults when possible.
     - Returns: An updated `MFASessionResult` reflecting the new MFA state and next actions.
     - Throws: `LoginIDError` if validation fails, the payload is missing/invalid, or the API call fails.
     */
    public func performAction(
        action: MfaActionAction.Name,
        options: PerformActionOptions?,
    ) async throws -> MFASessionResult {
        let appId = try config.getAppId()
        let info = store.getMFAInfo()
        let values = try MFAValidator.actionValidator(action: action, info: info, options: options)
        
        switch action {
        case .passkeyReg, .passkeyAuth, .passkeyTx:
            let passkeyOptions = try MFAValidator.validatePasskeyPayload(values.payload)
            switch passkeyOptions {
            case .creation(var creation):
                return try await invokeMfaApi(appId: appId, username: info?.username) {
                    // Display name trick
                    if let displayName = options?.displayName, !displayName.isEmpty {
                        creation = PublicKeyCredentialCreationOptions(
                            options: creation,
                            username: displayName
                        )
                    }
                    
                    let credential = try await CreateController().performRequests(
                        publicKey: creation
                    )
                    
                    let creationResult = CreationResult(
                        attestationObject: credential.attestationObject,
                        clientDataJSON: credential.clientDataJSON,
                        credentialId: credential.id
                    )
                    
                    let requestBody = MfaPasskeyRegRequestBody(creationResult: creationResult)
                    
                    return try await MfaAPI.mfaMfaPasskeyReg(
                        mfaPasskeyRegRequestBody: requestBody,
                        authorization: values.session,
                    )
                }
                
            case .request(let request):
                return try await invokeMfaApi(appId: appId, username: info?.username) {
                    let credential = try await GetController().performRequests(
                        publicKey: request,
                        autoFill: options?.autoFill ?? false
                    )
                    
                    let assertionResult = AuthenticatorAssertionResponse(
                        authenticatorData: credential.authenticatorData,
                        clientDataJSON: credential.clientDataJSON,
                        credentialId: credential.id,
                        signature: credential.signature,
                        userHandle: credential.userHandle

                    )
                    
                    let requestBody = MfaPasskeyAuthRequestBody(
                        assertionResult: assertionResult
                    )
                    
                    if (action == .passkeyTx) {
                        return try await MfaAPI.mfaMfaPasskeyTx(
                            mfaPasskeyAuthRequestBody: requestBody,
                            authorization: values.session,
                        )
                    }
                    
                    if (action == .passkeyAuth) {
                        return try await MfaAPI.mfaMfaPasskeyAuth(
                            mfaPasskeyAuthRequestBody: requestBody,
                            authorization: values.session,
                        )
                    }
                    
                    throw LoginIDError(
                        msgCode: "",
                        msg: "MFA factor \(action) is not supported in the current MFA flow."
                    )
                }
            }
            
        case .external:
            return try await invokeMfaApi(appId: appId, username: info?.username) {
                let requestBody = MfaThirdPartyAuthVerifyRequestBody(token: values.payload)
                return try await MfaAPI.mfaMfaThirdPartyAuthVerify(
                    mfaThirdPartyAuthVerifyRequestBody: requestBody,
                    authorization: values.session,
                )
            }
            
        default:
            throw LoginIDError(
                msgCode: "",
                msg: "MFA factor \(action) is not supported in the current MFA flow."
            )
        }
    }
    
    private func invokeMfaApi(
        appId: String,
        username: String?,
        _ fn: () async throws -> Mfa
    ) async throws -> MFASessionResult {
        do {
            let performActionResult = try await fn()
            let info = store.getMFAInfo()
            let successInfo = MFAInfo(username: username, flow: info?.flow)
            let tokenSet = TokenSet(result: performActionResult)
            
            store.storeMFAInfo(successInfo)
            store.storeDeviceId(performActionResult.deviceId)
            session.setTokenSet(tokenSet)
            
            return MFASessionResult(info: successInfo, tokenSet: tokenSet)
        } catch let LoginIDAPIClient.ErrorResponse.error(status, data, urlResponse, underlying)  {
            if status == 401,
               let data = data,
               let result = try? JSONCoding.decoder().decode(MfaNext.self, from: data),
               let session = result.session
            {
                let current = store.getMFAInfo()
                let info = MFAInfo(result: result, username: username)
                
                store.storeMFAInfo(info)
                
                return MFASessionResult(info: info, tokenSet: nil)
            }
            
            //TODO: Add client-events here after if it got here which means true error
            
            // Rethrow same error. Global TaskHandler should catch it.
            throw ErrorResponse.error(status, data, nil, underlying)
        } catch {
            throw error
        }
    }
}
