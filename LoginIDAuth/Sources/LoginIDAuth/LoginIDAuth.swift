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
    private let passkeyManager: PasskeyManager
    
    private let passkeysService: LoginIDPasskeyAPI
    private let passkeyManagementService: LoginIDPasskeyManagementAPI
    
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
        passkeyManagementService = PasskeyManagementService()

        credentials = MainActor.assumeIsolated { KeyCredentialManager() }
        
        passkeysController = Passkeys(
            config: config,
            deviceStore: deviceStore,
            sessionStore: sessionStore,
            credentials: credentials,
            trustStore: trustId,
            passkeyApi: passkeysService
        )
        
        passkeyManager = PasskeyManager(
            sessionStore: sessionStore,
            passkeyApi: passkeyManagementService
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
    
    /**
    This method initiates a non-repudiation signature process by generating a transaction-specific challenge
    and then expects the client to provide an assertion response using a passkey.
     
    This method is useful for confirming actions such as payments
    or changes to sensitive account information, ensuring that the transaction is being authorized
    by the rightful owner of the passkey.
     
    For a more detailed guide click [here](https://docs.loginid.io/user-scenario/authentication/step-up/transaction-confirmation/).
     
     - Parameters:
       - username: The username of the account holder confirming the transaction.
       - txPayload: A string representing the transaction details, such as an amount or action.
       - options: Optional parameters to customize the transaction, like providing a `nonce` or specifying the `txType`.
     - Returns: A `TxConfirmResult` containing a confirmation token and passkey details.
     - Throws: A `LoginIDError` if the transaction confirmation fails or is canceled.
     */
    public func confirmTransaction(
        username: String,
        txPayload: String,
        options: ConfirmTransactionOptions? = nil
    ) async throws -> TxConfirmResult {
        return try await TaskHandler.executeTask {
            try await self.passkeysController.confirmTransaction(
                username: username,
                txPayload: txPayload,
                options: options
            )
        }
    }
    
    /// This method returns list of passkeys associated with the current user. The user must be fully authorized for this call to succeed.
    /// - Parameter options: Options for the request, including an optional authorization token.
    /// - Returns: An array of `LoginIDPasskey` objects.
    /// - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
    public func listPasskeys(options: ListPasskeysOptions? = nil) async throws -> [PasskeyDetails] {
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.listPasskeys(options: options)
        }
    }
    
    /// This method returns list of passkeys associated with the current user. The user must be fully authorized for this call to succeed.
    /// - Parameter authzToken: Authorization token.
    /// - Returns: An array of `LoginIDPasskey` objects.
    /// - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
    public func listPasskeys(authzToken: String) async throws -> [PasskeyDetails] {
        let opts = ListPasskeysOptions(authzToken: authzToken)
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.listPasskeys(options: opts)
        }
    }

    /// Renames a specified passkey by ID. The user must be fully authorized for this call to succeed.
    /// - Parameters:
    ///   - id: The unique identifier of the passkey to rename.
    ///   - name: The new name for the passkey.
    ///   - options: Options for the request, including an optional authorization token.
    /// - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
    public func renamePasskey(id: String, name: String, options: RenamePasskeyOptions? = nil) async throws {
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.renamePasskey(id: id, name: name, options: options)
        }
    }
    
    /// Renames a specified passkey by ID. The user must be fully authorized for this call to succeed.
    /// - Parameters:
    ///   - id: The unique identifier of the passkey to rename.
    ///   - name: The new name for the passkey.
    ///   - authzToken: Authorization token.
    /// - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
    public func renamePasskey(id: String, name: String, authzToken: String) async throws {
        let opts = RenamePasskeyOptions(authzToken: authzToken)
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.renamePasskey(id: id, name: name, options: opts)
        }
    }

    /// Delete a specified passkey by ID from LoginID. The user must be fully authorized for this call to succeed.
    /// - Parameters:
    ///   - id: The unique identifier of the passkey to delete.
    ///   - options: Options for the request, including an optional authorization token.
    /// - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
    public func deletePasskey(id: String, options: DeletePasskeyOptions? = nil) async throws {
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.deletePasskey(id: id, options: options)
        }
    }
    
    /// Delete a specified passkey by ID from LoginID. The user must be fully authorized for this call to succeed.
    /// - Parameters:
    ///   - id: The unique identifier of the passkey to delete.
    ///   - authzToken: Authorization token.
    /// - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
    public func deletePasskey(id: String, authzToken: String) async throws {
        let opts = DeletePasskeyOptions(authzToken: authzToken)
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.deletePasskey(id: id, options: opts)
        }
    }
}
