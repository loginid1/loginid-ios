//
//  Passkeys.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-24.
//

import LoginIDCore

/// Provides the core interface for performing passkey authentication flows with LoginID FIDO2 service.
final class Passkeys : Sendable {
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
        passkeyApi: LoginIDPasskeyAPI
    ) {
        self.config = config
        self.deviceStore = deviceStore
        self.session = sessionStore
        self.passkeyApi = passkeyApi
        self.trustId = trustStore
        self.credentials = credentials
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
                    clientDataJSON: credential.clientDataJSON,
                    credentialId: credential.id
                ),
                passkeyName: options?.passkeyName,
                session: initRes.session
            )
            
            let result = try await RegAPI.regRegComplete(
                    regCompleteRequestBody: regCompleteRequestBody
                )

            session.setAccessToken(result.jwtAccess)
            deviceStore.storeDeviceId(result.deviceId)

            return AuthResult(result: result)
        }
    }
    
    private func invokePasskeyApi<T>(
        session _: String,
        _ fn: () async throws -> T
    ) async throws -> T {
        do {
            let result = try await fn()
            return result
        } catch {
            // TODO: add client events here at some point
            throw error
        }
    }
}
