//
//  LoginIDAuth.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2025-07-31.
//

import LoginIDCore

@_exported import LoginIDCore

/// The main entry point for the LoginIDAuth package.
/// Provides access to all SDK functionality, including configuration,
/// and LoginID standalone authentication services.
final public class LoginIDAuth: Sendable {
    private let clientEvents: LoginIDClientEventsAPI
    private let credentials: KeyCredentialManaging
    private let sessionStore: SessionManaging
    private let deviceStore: DeviceStoring
    private let trustId: TrustIDManaging
    private let config: LoginIDConfig
    
    private let passkeysController: Passkeys
    private let passkeyManager: PasskeyManager
    private let otpController: OTP
    private let utilsController: Utils
    
    private let passkeysService: LoginIDPasskeyAPI
    private let passkeyManagementService: LoginIDPasskeyManagementAPI
    private let otpService: LoginIDOTPAPI
    
    /**
     Creates a new `LoginIDAuth` instance using a `LoginIDConfig` object.
     
     - Parameter config: The configuration object for the LoginID API.
     */
    public init(config: LoginIDConfig) {
        self.config = config
        OpenAPIClientAPIConfiguration.shared.basePath = config.baseUrl
        
        let appId = config.getAppIdOrEmpty()
        
        deviceStore = DeviceStore(appId: appId)
        sessionStore = SessionManager(appId: appId)
        trustId = TrustID(appId: appId)
        passkeysService = PasskeyService()
        passkeyManagementService = PasskeyManagementService()
        otpService = OTPService()
        clientEvents = ClientEventsService(config: config)

        credentials = MainActor.assumeIsolated { KeyCredentialManager() }
        
        passkeysController = Passkeys(
            config: config,
            deviceStore: deviceStore,
            sessionStore: sessionStore,
            credentials: credentials,
            trustStore: trustId,
            passkeyApi: passkeysService,
            clientEvents: clientEvents
        )
        
        passkeyManager = PasskeyManager(
            sessionStore: sessionStore,
            passkeyApi: passkeyManagementService
        )
        
        otpController = OTP(
            sessionStore: sessionStore,
            otpApi: otpService
        )
        
        utilsController = Utils(
            config: config,
            passkeyApi: passkeysService,
            sessionManager: sessionStore
        )
    }

    /**
     Creates a new `LoginIDAuth` instance using a base URL string.
     
     - Parameter baseUrl: The base URL for the LoginID API.
     */
    public convenience init(baseUrl: String) {
        let config = LoginIDConfig(baseUrl: baseUrl)
        self.init(config: config)
    }

    /**
     This method helps to create a passkey. The only required parameter is the username, but additional attributes can be provided in the options parameter.
     Note: While the authorization token is optional, it must always be used in a production environment. You can skip it during development by adjusting
     the app configuration in the LoginID dashboard.
     
     A short-lived authorization token is returned, allowing access to protected resources for the given user such as listing, renaming or deleting passkeys.
     
     - Parameters:
       - username: The username for which to create the passkey.
       - options: Optional parameters for passkey creation.
     - Returns: An `AuthResult` containing an authorization token.
     - Throws: A `LoginIDError` if passkey creation fails.
     */
    public func createPasskey(
        username: String,
        options: CreatePasskeyOptions? = nil
    ) async throws -> AuthResult {
        return try await TaskHandler.executeTask {
            try await self.passkeysController.createPasskey(username: username, options: options)
        }
    }
    
    /**
     This method helps to create a passkey. The only required parameter is the username, but additional attributes can be provided in the options parameter.
     Note: While the authorization token is optional, it must always be used in a production environment. You can skip it during development by adjusting
     the app configuration in the LoginID dashboard.
     
     A short-lived authorization token is returned, allowing access to protected resources for the given user such as listing, renaming or deleting passkeys.

     - Parameters:
       - username: The username for which to create the passkey.
       - authzToken: An authorization token from a previous authentication step.
       - options: Optional parameters for passkey creation.
     - Returns: An `AuthResult` containing an authorization token.
     - Throws: A `LoginIDError` if passkey creation fails.
     */
    public func createPasskey(
        username: String,
        authzToken: String,
        options: CreatePasskeyOptions? = nil
    ) async throws -> AuthResult {
        let opts = CreatePasskeyOptions(authzToken: authzToken, options: options)
        return try await TaskHandler.executeTask {
            try await self.passkeysController.createPasskey(username: username, options: opts)
        }
    }
    
    /**
     This method authenticates a user with a passkey and may trigger additional browser dialogs to guide the user through the process.
     
     A short-lived authorization token is returned, allowing access to protected resources for the given user such as listing, renaming or deleting passkeys.
     
     - Parameters:
       - username: The username of the user to authenticate.
       - options: Optional parameters for passkey authentication.
     - Returns: An `AuthResult` containing an authorization token if authentication is successful.
     - Throws: A `LoginIDError` if authentication fails.
     */
    public func authenticateWithPasskey(
        username: String,
        options: AuthenticateWithPasskeyOptions? = nil
    ) async throws -> AuthResult {
        return try await TaskHandler.executeTask {
            try await self.passkeysController.authenticateWithPasskey(username: username, options: options)
        }
    }
    
    /**
     Authenticates a user by utilizing the browser's passkey autofill capabilities.
     
     A short-lived authorization token is returned, allowing access to protected resources for the given user such as listing, renaming or deleting passkeys.
     
     - Parameter options: Optional parameters for passkey authentication.
     - Returns: An `AuthResult` containing an authorization token if authentication is successful.
     - Throws: A `LoginIDError` if authentication fails or is canceled.
     */
    public func authenticateWithPasskeyAutofill(
        options: AuthenticateWithPasskeyOptions? = nil
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
    
    /**
     This method returns list of passkeys associated with the current user. The user must be fully authorized for this call to succeed.
     
     - Parameter options: Options for the request, including an optional authorization token.
     - Returns: An array of `LoginIDPasskey` objects.
     - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
     */
    public func listPasskeys(options: ListPasskeysOptions? = nil) async throws -> [PasskeyDetails] {
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.listPasskeys(options: options)
        }
    }
    
    /**
     This method returns list of passkeys associated with the current user. The user must be fully authorized for this call to succeed.
     
     - Parameter authzToken: Authorization token.
     - Returns: An array of `LoginIDPasskey` objects.
     - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
     */
    public func listPasskeys(authzToken: String) async throws -> [PasskeyDetails] {
        let opts = ListPasskeysOptions(authzToken: authzToken)
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.listPasskeys(options: opts)
        }
    }

    /**
     Renames a specified passkey by ID. The user must be fully authorized for this call to succeed.
     
     - Parameters:
       - id: The unique identifier of the passkey to rename.
       - name: The new name for the passkey.
       - options: Options for the request, including an optional authorization token.
     - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
     */
    public func renamePasskey(id: String, name: String, options: RenamePasskeyOptions? = nil) async throws {
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.renamePasskey(id: id, name: name, options: options)
        }
    }
    
    /**
     Renames a specified passkey by ID. The user must be fully authorized for this call to succeed.
     
     - Parameters:
       - id: The unique identifier of the passkey to rename.
       - name: The new name for the passkey.
       - authzToken: Authorization token.
     - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
     */
    public func renamePasskey(id: String, name: String, authzToken: String) async throws {
        let opts = RenamePasskeyOptions(authzToken: authzToken)
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.renamePasskey(id: id, name: name, options: opts)
        }
    }

    /**
     Delete a specified passkey by ID from LoginID. The user must be fully authorized for this call to succeed.
     
     - Parameters:
       - id: The unique identifier of the passkey to delete.
       - options: Options for the request, including an optional authorization token.
     - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
     */
    public func deletePasskey(id: String, options: DeletePasskeyOptions? = nil) async throws {
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.deletePasskey(id: id, options: options)
        }
    }
    
    /**
     Delete a specified passkey by ID from LoginID. The user must be fully authorized for this call to succeed.
     
     - Parameters:
       - id: The unique identifier of the passkey to delete.
       - authzToken: Authorization token.
     - Throws: A `LoginIDError` if the user is not authenticated or the request fails.
     */
    public func deletePasskey(id: String, authzToken: String) async throws {
        let opts = DeletePasskeyOptions(authzToken: authzToken)
        return try await TaskHandler.executeTask {
            try await self.passkeyManager.deletePasskey(id: id, options: opts)
        }
    }
    
    /**
     This method returns a one-time OTP to be displayed on the current device. The user must be authenticated on this device. The OTP is meant for cross-authentication, where the user reads the OTP from the screen and enters it on the target device.
     
     - Parameter options: Options for the request, including an optional authorization token.
     - Returns: An `OTPResult` containing the generated code and its expiration details.
     - Throws: A `LoginIDError` if the request fails.
     */
    public func requestOtp(
        options: RequestOtpOptions? = nil
    ) async throws -> OTPResult {
        return try await TaskHandler.executeTask {
            try await self.otpController.requestOtp(options: options)
        }
    }
    
    /**
     This method verifies the OTP and returns an authorization token, which can be used with the `passkeyCreate()`
     method to create a new passkey. The authorization token has a short validity period and should be used immediately.
     
     - Parameters:
       - username: The username of the account being authenticated.
       - otp: The one-time password entered by the user.
       - options: Optional parameters to customize the request, such as `usernameType`.
     - Returns: An `AuthResult` with tokens if the OTP is valid.
     - Throws: A `LoginIDError` if validation fails.
     */
    public func validateOtp(
        username: String,
        otp: String,
        options: ValidateOtpOptions? = nil
    ) async throws -> AuthResult {
        return try await TaskHandler.executeTask {
            try await self.otpController.validateOtp(username: username, otp: otp, options: options)
        }
    }
    
    /**
     This method requests an OTP from the backend to be sent via the selected method. The method of delivery should be based on
     the user's choice from the list of available options. This can be found in the result of `authenticateWithPasskey`
     method as `fallbackOptions`.
     
     - Parameters:
       - username: The username to send the OTP to.
       - method: The delivery channel, either `.email` or `.sms`. Defaults to `.email`.
       - options: Optional parameters to customize the request, such as `usernameType`.
     - Throws: A `LoginIDError` if the OTP cannot be sent.
     */
    public func requestAndSendOtp(
        username: String,
        method: MessageMethod = .email,
        options: RequestAndSendOtpOptions? = nil
    ) async throws {
        return try await TaskHandler.executeTask {
            try await self.otpController.requestAndSendOtp(username: username, method: method, options: options)
        }
    }
    
    /**
     Validates the application's configuration settings and provides a suggested correction if any issues are detected.
     
     - Returns: A `LoginIDConfigResult` if there is a configuration issue, otherwise `nil`.
     */
    public func verifyConfigSettings() async -> LoginIDConfigResult? {
        return await utilsController.verifyConfigSettings()
    }

    /**
     Check whether the user of the current browser session is authenticated and returns user info.
     This info is retrieved locally and no requests to backend are made.
     
     - Returns: A `SessionInfo` object if a valid session exists, otherwise `nil`.
     */
    public func getSessionInfo() -> SessionInfo? {
        return utilsController.getSessionInfo()
    }

    /**
     Clears current user session. This method ideletes the authorization token locally.
     */
    public func logout() {
        utilsController.logout()
    }
}
