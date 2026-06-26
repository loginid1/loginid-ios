//
//  LoginIDAuth.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2025-07-31.
//

import LoginIDCore

/// The main entry point for the LoginIDAuth package.
/// Provides access to all SDK functionality, including configuration,
/// and LoginID standalone authentication services.
final public class LoginIDAuthKit: Sendable {
    private let credentials: KeyCredentialManaging
    private let sessionStore: SessionManaging
    private let deviceStore: DeviceStoring
    private let trustId: TrustIDManaging
    private let config: LoginIDConfig
    
    private let passkeysController: Passkeys
    
    private let passkeysService: LoginIDPasskeyAPI
    
    /**
     Creates a new `LoginIDAuth` instance using a base URL string.
     
     - Parameter baseUrl: The base URL for the LoginID API.
     */
    public init(baseUrl: String) {
        config = LoginIDConfig(baseUrl: baseUrl)
        OpenAPIClientAPIConfiguration.shared.basePath = baseUrl
        
        let appId = config.getAppIdOrEmpty()
        
        deviceStore = DeviceStore(appId: appId)
        sessionStore = SessionManager(appId: appId)
        trustId = TrustID(appId: appId)
        passkeysService = PasskeyService()

        credentials = MainActor.assumeIsolated { KeyCredentialManager() }
        
        passkeysController = Passkeys(
            config: config,
            deviceStore: deviceStore,
            sessionStore: sessionStore,
            credentials: credentials,
            trustStore: trustId,
            passkeyApi: passkeysService,
        )
    }

    public func createPasskey(
        username: String,
        options: CreatePasskeyOptions?
    ) async throws -> AuthResult {
        return try await TaskHandler.executeTask {
            try await self.passkeysController.createPasskey(username: username, options: options)
        }
    }
    
    public func createPasskey(
        username: String,
        authzToken: String,
        options: CreatePasskeyOptions?
    ) async throws -> AuthResult {
        let opts = CreatePasskeyOptions(authzToken: authzToken, options: options)
        return try await TaskHandler.executeTask {
            try await self.passkeysController.createPasskey(username: username, options: opts)
        }
    }
    
    public func authenticateWithPasskey(
        username: String,
        options: AuthenticateWithPasskeyOptions?
    ) async throws -> AuthResult {
        return try await TaskHandler.executeTask {
            try await self.passkeysController.authenticateWithPasskey(username: username, options: options)
        }
    }
    
    public func authenticateWithPasskeyAutofill(
        options: AuthenticateWithPasskeyOptions?
    ) async throws -> AuthResult {
        let opts = AuthenticateWithPasskeyOptions(options: options)
        return try await TaskHandler.executeTask {
            try await self.passkeysController.authenticateWithPasskey(username: "", options: opts)
        }
    }
}
