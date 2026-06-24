//
//  LoginID.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-07-31.
//

import LoginIDAPIClient

@_exported import LoginIDCore
@_exported import LoginIDMFA

/**
 A specialized authentication helper built on top of LoginID's MFA flow, designed for checkout scenarios
 where you need both authentication and identity trust.

 This helps orchestrate the MFA flow tied to a transaction (e.g., confirming a purchase) using passkeys.
 */
final public class LoginID: Sendable {
    private let mfa: LoginIDMFA.LoginIDMFAKit
    private let store: WalletAuthStoring
    
    /**
     Creates a new wallet authentication helper using a base URL.

     Use this initializer when you only have the environment base URL and want sensible defaults
     for the underlying SDK configuration.

     - Parameter baseUrl: The LoginID environment base URL (e.g., from your environment configuration).
     */
    public init(baseUrl: String) {
        self.mfa = LoginIDMFA.LoginIDMFAKit(baseUrl: baseUrl)
        
        let appId = LoginIDConfig(baseUrl: baseUrl).getAppIdOrEmpty()
        
        self.store = WalletAuthStore(appId: appId)
    }
    
    /**
     Creates a new wallet authentication helper with an explicit `LoginIDConfig`.

     Use this when you already have a fully-formed `LoginIDConfig` and want more control.

     - Parameter config: The complete configuration used to initialize the underlying LoginID SDK.
     */
    public init(config: LoginIDConfig) {
        self.mfa = LoginIDMFA.LoginIDMFAKit(config: config)
        
        let appId = config.getAppIdOrEmpty()
        
        self.store = WalletAuthStore(appId: appId)
    }
    
    /**
     Begins the MFA authentication flow for a checkout session.

     This starts an MFA session bound to a specific **transaction payload** and optional identifiers
     such as merchant `checkoutId`.

     - Parameters:
       - options: Options for beginning the flow. Provide:
         - `username`: Optional username (empty string will be used if `nil`).
         - `txPayload`: **Required.** The transaction payload to be confirmed/authorized.
         - `checkoutId`: Optional merchant side identifier.
         - `traceId`: Optional trace identifier for observability.

     - Returns: An `MFASessionResult` describing the newly-started MFA session.

     - Throws: `LoginIDError` if validation fails (e.g., missing `txPayload`) or if the underlying SDK
       encounters an error.
       ```
     */
    public func beginFlow(
        options: BeginFlowOptions
    ) async throws -> MFASessionResult {
        if options.txPayload.isEmpty {
           throw LoginIDError(
            msgCode: "not_found",
            msg: "TX payload is required"
           )
        }
        
        let username = options.username ?? ""
        let opts = LoginIDMFA.BeginFlowOptions(
            txPayload: options.txPayload,
            merchantTrustId: options.merchantTrustId,
            traceId: options.traceId,
            deviceId: options.deviceId,
        )
        
        store.storeCheckoutId(options.merchantTrustId)
        store.storeTraceId(options.traceId)
        
        return try await mfa.beginFlow(
            username: username,
            options: opts
        )
    }
    
    /**
     Performs an MFA action using the provided factor and optional payload.

     In a checkout context, this method commonly covers:
     - **Passkey Registration (`.passkeyReg`)**: Register a new passkey (e.g., WebAuthn) during account creation.
     - **Passkey Authentication (`.passkeyAuth`)**: signin into a wallet account using a passkey.
     - **Passkey Transaction Confirmation (`.passkeyTx`)**:  Confirm a specific transaction using a passkey.
     - **External Authentication (`.external`)**:  Signin with a third-party authentication (e.g. bank login).

     - Parameters:
       - action: The MFA factor/action to execute.
       - options: Action options such as:
         - `payload`: Optional action-specific payload (e.g., authorization tokens, OTP,  assertion data).
         - `autoFill`: Optional passkey autofill.
         - `displayName`: Optional display name for passkey registration (.paddkeyReg).
         - `txPayload`: An optional transaction payload (relevant for .passkeyTx) that can be used to update the current session’s txPayload if needed.

     - Returns: An updated `MFASessionResult` after performing the requested action.

     - Throws: Any error encountered by the underlying SDK, or validation errors if inputs are missing.
       ```
     */
    public func performAction(
        action: MfaActionAction.Name,
        options: PerformActionOptions?
    ) async throws -> MFASessionResult {
        let opts = LoginIDMFA.PerformActionOptions(
            payload: options?.payload,
            autoFill: options?.autoFill,
            displayName: options?.displayName,
            txPayload: options?.txPayload
        )
        
        return try await mfa.performAction(
            action: action,
            options: opts
        )
    }
    
    /**
     Performs an MFA action using the provided factor and optional payload.

     In a checkout context, this method commonly covers:
     - **Passkey Registration (`.passkeyReg`)**: Register a new passkey (e.g., WebAuthn) during account creation.
     - **Passkey Authentication (`.passkeyAuth`)**: signin into a wallet account using a passkey.
     - **Passkey Transaction Confirmation (`.passkeyTx`)**:  Confirm a specific transaction using a passkey.
     - **External Authentication (`.external`)**:  Signin with a third-party authentication (e.g. bank login).

     - Parameters:
       - action: The MFA factor/action to execute.

     - Returns: An updated `MFASessionResult` after performing the requested action.

     - Throws: Any error encountered by the underlying SDK, or validation errors if inputs are missing.
       ```
     */
    public func performAction(
        action: MfaActionAction.Name,
    ) async throws -> MFASessionResult {
        return try await self.performAction(
            action: action,
            options: nil
        )
    }
}
