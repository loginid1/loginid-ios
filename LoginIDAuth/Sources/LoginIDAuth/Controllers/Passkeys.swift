//
//  Passkeys.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-24.
//

import LoginIDCore

/// Provides the core interface for performing passkey authentication flows with LoginID FIDO2 service.
internal final class Passkeys : Sendable {
    private let clientEvents: LoginIDClientEventsAPI
    private let credentials: KeyCredentialManaging
    private let passkeyApi: LoginIDPasskeyAPI
    private let deviceStore: DeviceStoring
    private let session: SessionManaging
    private let trustId: TrustIDManaging
    private let config: LoginIDConfig
    
    init(
        config: LoginIDConfig,
        deviceStore: DeviceStoring,
        sessionStore: SessionManaging,
        credentials: KeyCredentialManaging,
        trustStore: TrustIDManaging,
        passkeyApi: LoginIDPasskeyAPI,
        clientEvents: LoginIDClientEventsAPI
    ) {
        self.config = config
        self.deviceStore = deviceStore
        self.session = sessionStore
        self.passkeyApi = passkeyApi
        self.trustId = trustStore
        self.credentials = credentials
        self.clientEvents = clientEvents
    }
    
    public func createPasskey(
        username: String,
        options: CreatePasskeyOptions?
    ) async throws -> AuthResult {
        let appId = try config.getAppId()
        let deviceInfo = await Defaults.deviceInfo(store: deviceStore, deviceId: options?.deviceId)
        let trustItems = try Defaults.trustItems(config: config, store: trustId, username: username)
        let user = Defaults.user(
            displayName: options?.displayName,
            username: username,
            usernameType: options?.usernameType
        )
        
        let regInitRequestBody = RegInitRequestBody(
            app: Application(id: appId),
            deviceInfo: deviceInfo,
            traceId: options?.traceId,
            trustItems: trustItems,
            user: user
        )
        
        let customUserAgent = await DeviceUtils.getUserAgent()
        let authzToken = session.getAuthzToken(authzToken: options?.authzToken)
        
        let initRes = try await passkeyApi.regInit(
            request: regInitRequestBody,
            userAgent: customUserAgent,
            authorization: authzToken
        )
        
        return try await invokePasskeyApi(session: initRes.session) {
            let credential = try await credentials.create(
                options: initRes.registrationRequestOptions,
            )
            
            let regCompleteRequestBody = RegCompleteRequestBody(
                creationResult: CreationResult(
                    attestationObject: credential.attestationObject,
                    authenticatorAttachment: credential.authenticatorAttachment,
                    clientDataJSON: credential.clientDataJSON,
                    credentialId: credential.id
                ),
                passkeyName: options?.passkeyName,
                session: initRes.session
            )
            
            let result = try await passkeyApi.regComplete(
                request: regCompleteRequestBody
            )

            session.setAccessToken(result.jwtAccess)
            deviceStore.storeDeviceId(result.deviceId)

            return AuthResult(result: result)
        }
    }
    
    public func authenticateWithPasskey(
        username: String,
        options: AuthenticateWithPasskeyOptions?
    ) async throws -> AuthResult {
        let appId = try config.getAppId()
        let deviceInfo = await Defaults.deviceInfo(store: deviceStore, deviceId: options?.deviceId)
        let trustItems = try Defaults.trustItems(config: config, store: trustId, username: username)
        let user = Defaults.userLogin(
            username: username,
            usernameType: options?.usernameType
        )
        let tx: TxPayload? =
            if let txPayload = options?.txPayload, !txPayload.isEmpty {
                TxPayload(data: txPayload, nonce: options?.txNonce ?? "")
            } else {
                nil
            }

        let authInitRequestBody = AuthInitRequestBody(
            app: Application(id: appId),
            deviceInfo: deviceInfo,
            traceId: options?.traceId,
            trustItems: trustItems,
            tx: tx,
            user: user
        )

        let customUserAgent = await DeviceUtils.getUserAgent()
        
        let initRes = try await passkeyApi.authInit(
            request: authInitRequestBody,
            userAgent: customUserAgent
        )

        switch initRes.action {
        case .proceed:
            guard let publicKey = initRes.assertionOptions else {
                throw LoginIDError(
                    msgCode: "passkey_authentication_failed",
                    msg: "Assertion options not found or invalid"
                )
            }
            
            return try await invokePasskeyApi(session: initRes.session) {
                let autofill = Defaults.autoFill(options?.autofill)
                let credential = try await self.credentials.get(
                    options: publicKey,
                    autoFill: autofill
                )

                let authCompleteRequestBody = AuthCompleteRequestBody(
                    assertionResult: AuthenticatorAssertionResponse(
                        authenticatorData: credential.authenticatorData,
                        clientDataJSON: credential.clientDataJSON,
                        credentialId: credential.id,
                        signature: credential.signature,
                        userHandle: credential.userHandle
                    ),
                    session: initRes.session
                )
                
                let result = try await passkeyApi.authComplete(
                    request: authCompleteRequestBody
                )

                session.setAccessToken(result.jwtAccess)
                deviceStore.storeDeviceId(result.deviceId)

                return AuthResult(result: result)
            }
        case .crossauth, .fallback:
            let fallbackOptions = initRes.mergeFallbackMethods()
            return AuthResult(fallbackOptions: fallbackOptions)
        }
    }

    /**
     Confirms a transaction with a passkey.

     This method initiates a transaction confirmation flow, prompts the user to
     approve the transaction with their passkey, and returns a confirmation token
     upon success.

     - Parameters:
       - username: The username of the account holder.
       - txPayload: A string representing the transaction details to be confirmed.
       - options: Optional parameters to customize the transaction, such as a nonce or transaction type.
     - Returns: A `TxConfirmResult` containing the transaction confirmation details.
     - Throws: A `LoginIDError` if the transaction confirmation fails.
     */
    public func confirmTransaction(
        username: String,
        txPayload: String,
        options: ConfirmTransactionOptions?
    ) async throws -> TxConfirmResult {
        let nonce = Defaults.nonce(options?.nonce)
        let txType = Defaults.txType(options?.txType)
        
        let txInitRequestBody = TxInitRequestBody(
            nonce: nonce,
            txPayload: txPayload,
            txType: txType,
            username: username
        )

        let initRes = try await passkeyApi.txInit(request: txInitRequestBody)

        let credential = try await credentials.get(
            options: initRes.assertionOptions,
            autoFill: false
        )

        let txCompleteRequestBody = TxCompleteRequestBody(
            authenticatorData: credential.authenticatorData,
            clientData: credential.clientDataJSON,
            keyHandle: credential.id,
            session: initRes.session,
            signature: credential.signature
        )

        let result = try await passkeyApi.txComplete(request: txCompleteRequestBody)

        return TxConfirmResult(result: result)
    }
    
    private func invokePasskeyApi<T>(
        session: String,
        _ fn: () async throws -> T
    ) async throws -> T {
        do {
            let result = try await fn()
            return result
        } catch {
            _ = try? await clientEvents.submitASAuthorizationErrorEvent(
                error: error,
                session: session
            )
            throw error
        }
    }
}
