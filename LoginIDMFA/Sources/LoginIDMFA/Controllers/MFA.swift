//
//  MFA.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDAPIClient

final class MFA : Sendable {
    private let trustId: TrustIDManaging
    private let session: SessionManaging
    private let config: LoginIDConfig
    private let store: MFAStoring
    
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
    
    public func beginFlow(
        username: String,
        options: BeginFlowOptions?
    ) async throws -> MFASessionResult {
        let deviceId = store.getDeviceId()
        let deviceInfo = await DeviceUtils.getDeviceInfo(deviceId: deviceId)
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
            //TODO: Add a realish userAgent header here after
            userAgent: "iOS",
            mfaBeginRequestBody: mfaBeginRequestBody,
        )
        
        let info = MFAInfo(result: mfaNextResult, username: username)
        
        session.logout()
        store.storeMFAInfo(info)
        
        return MFASessionResult(info: info, tokenSet: nil)
    }
    
    public func performAction(
        action: MfaActionAction.Name,
        options: PerformActionOptions?,
    ) async throws -> MFASessionResult {
        let appId = try config.getAppId()
        let info = store.getMFAInfo()
        let values = try MFAValidator.actionValidator(action: action, info: info, options: options)
        
        switch action {
        case .passkeyReg, .passkeyAuth, .passkeyTx:
            let options = try MFAValidator.validatePasskeyPayload(values.payload)
            switch options {
            case .creation(let creation):
                return try await invokeMfaApi(appId: appId, username: info?.username) {
                    //TODO: add displayName here
                    
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
                        publicKey: request
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
                        return try await MfaAPI.mfaMfaPasskeyAuth(
                            mfaPasskeyAuthRequestBody: requestBody,
                            authorization: values.session,
                        )
                    }
                    
                    if (action == .passkeyAuth) {
                        return try await MfaAPI.mfaMfaPasskeyTx(
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
            
            return MFASessionResult(info: info, tokenSet: tokenSet)
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
