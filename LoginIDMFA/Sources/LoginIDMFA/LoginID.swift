//
//  LoginID.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-07-31.
//

import LoginIDAPIClient
import Foundation
import LoginIDCore

/// The main entry point for the LoginID MFA SDK package.
///
/// Provides access to all SDK functionality, including configuration,
/// MFA flows, secure session management, and device trust handling.
final public class LoginID: Sendable {
    private let credentials: KeyCredentialManaging
    private let trustId: TrustIDManaging
    private let session: SessionManaging
    private let config: LoginIDConfig
    private let store: MFAStore
    private let mfa: MFA
    
    /**
     Creates a new `LoginID` instance using a base URL string.
     
     - Parameter baseUrl: The base URL for the LoginID API.
     */
    public init(baseUrl: String) {
        config = LoginIDConfig(baseUrl: baseUrl)
        
        OpenAPIClientAPIConfiguration.shared.basePath = baseUrl
        
        let appId = config.getAppIdOrEmpty()
        
        store = MFAStore(appId: appId)
        session = SessionManager(appId: appId)
        trustId = TrustID()
        
        credentials = MainActor.assumeIsolated { KeyCredentialManager() }
        
        mfa = MFA(
            config: config,
            store: store,
            session: session,
            trustId: trustId,
            credentials: credentials
        )
    }
    
    /**
     Creates a new `LoginID` instance using a preconfigured `LoginIDConfig`.
     
     - Parameter config: A `LoginIDConfig` containing API configuration values.
     */
    public init(config: LoginIDConfig) {
        self.config = config
        
        OpenAPIClientAPIConfiguration.shared.basePath = config.getBaseUrl()

        let appId = config.getAppIdOrEmpty()
        
        store = MFAStore(appId: appId)
        session = SessionManager(appId: appId)
        trustId = TrustID()
        
        credentials = MainActor.assumeIsolated { KeyCredentialManager() }
        
        mfa = MFA(
            config: config,
            store: store,
            session: session,
            trustId: trustId,
            credentials: credentials
        )
    }
    
    /**
     Initiates the pre-authentication process for Multi-Factor Authentication (MFA).

     Begins an MFA session and persists session details to secure storage.

     Use `performAction(_:_:)` to continue the MFA flow with a required payload when needed.
     To check the current session status, call `getMfaSessionDetails()`.

     - Parameters:
       - username: The username of the user initiating MFA.
       - options: Optional parameters for initiating MFA. Pass `nil` to use defaults.
     - Returns: An `MFASessionResult` describing the current MFA session state and next actions.
     - Throws: `LoginIDError` if the request fails or the response is invalid.
     */
    public func beginFlow(
        username: String,
        options: BeginFlowOptions?,
    ) async throws -> MFASessionResult {
        return try await TaskHandler.executeTask {
            try await self.mfa.beginFlow(username: username, options: options)
        }
    }
    
    /**
     Performs a Multi-Factor Authentication (MFA) action using the specified factor.

     Supports passkeys, OTP (email/SMS), and external authentication. Validates the
     provided options, processes the step, calls the corresponding MFA API, and updates
     the MFA session details upon success.

     - Important:
       - **OTP Request (email/SMS):** Sends an OTP to the user's contact. If `options.payload`
         contains a contact, it is used; otherwise, the primary contact on record is used.
       - **OTP Verify (email/SMS):** Verifies the OTP code provided in `options.payload`.
       - **External authentication:** Provide the authorization code in `options.payload`.
       - **Passkeys:** Uses WebAuthn for authentication or registration.

     - Parameters:
       - action: The MFA factor to perform (e.g., `.passkeyAuth`, `.otpEmail`, `.otpSms`, `.external`).
       - options: The session/payload options for the action. Pass `nil` to resolve defaults when possible.
     - Returns: An updated `MFASessionResult` reflecting the new MFA state and next actions.
     - Throws: `LoginIDError` if validation fails, the payload is missing/invalid, or the API call fails.
     */
    public func performAction(
        action: MfaActionAction.Name,
        options: PerformActionOptions?,
    ) async throws -> MFASessionResult {
        return try await TaskHandler.executeTask {
            try await self.mfa.performAction(action: action, options: options)
        }
    }
}
