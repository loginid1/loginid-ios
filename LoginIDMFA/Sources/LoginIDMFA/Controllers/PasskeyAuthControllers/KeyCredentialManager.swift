//
//  KeyCredentialManager.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-16.
//

import AuthenticationServices

/**
 Protocol defining the operations for managing WebAuthn-compatible key credentials.
 
 Conformers provide methods for both creating new credentials and retrieving
 existing ones, wrapping platform APIs in Swift's async/await model.
 */
protocol KeyCredentialManaging: Sendable {
    /**
     Initiates a passkey creation flow.
     
     - Parameter options: The `PublicKeyCredentialCreationOptions` that describe the
       relying party, challenge, and user information for credential registration.
     
     - Returns: A `CreatePublicKeyResponse` containing the credential’s ID, raw ID,
       client data, and attestation object.
     
     - Throws: An error if the credential creation fails or the response is invalid.
     */
    func create(options: PublicKeyCredentialCreationOptions) async throws -> CreatePublicKeyResponse
    
    /**
     Initiates a passkey retrieval (authentication) flow.
     
     - Parameters:
       - options: The `PublicKeyCredentialRequestOptions` including the challenge and
         relying party information used for authentication.
       - autoFill: A Boolean indicating whether to enable iOS AutoFill for passkey suggestions.
     
     - Returns: A `GetPublicKeyResponse` containing the credential’s ID, raw ID,
       client data, and authenticator data.
     
     - Throws: An error if retrieval fails or the response is invalid.
     */
    func get(options: PublicKeyCredentialRequestOptions, autoFill: Bool) async throws -> GetPublicKeyResponse
}

/**
 Protocol adopted by credential authorizers that manage
 in-progress platform authentication or registration flows.
 */
@MainActor
protocol KeyAuthorizer {
    /**
     Cancels the current credential flow, if one is active.
     
     - Important: Dismissing the system-provided UI will terminate the
       request and result in no credential being created or retrieved.
     */
    func cancel() -> Void
}

/**
 Coordinates creation and retrieval of passkeys on iOS,
 managing the lifecycle of underlying authorization controllers.
 
 Ensures only one credential flow is active at a time by cancelling
 any existing request before starting a new one.
 */
@MainActor
final class KeyCredentialManager: KeyCredentialManaging {
    /// Tracks the current in-progress authorizer, if any.
    private var authorizer: KeyAuthorizer? = nil
    
    /**
     Starts a new credential creation flow, cancelling any active flow first.
     
     - Parameter options: The `PublicKeyCredentialCreationOptions` describing
       the credential to be created.
     
     - Returns: A `CreatePublicKeyResponse` containing the resulting credential data.
     */
    func create(
        options: PublicKeyCredentialCreationOptions,
    ) async throws -> CreatePublicKeyResponse {
        await cancel()
        
        let controller = await CreateController()
        authorizer = controller
        return try await controller.performRequests(publicKey: options)
    }
    
    /**
     Starts a new credential retrieval flow, cancelling any active flow first.
     
     - Parameters:
       - options: The `PublicKeyCredentialRequestOptions` describing the request.
       - autoFill: A Boolean indicating whether to allow AutoFill to suggest passkeys.
     
     - Returns: A `GetPublicKeyResponse` containing the resulting credential data.
     */
    func get(
        options: PublicKeyCredentialRequestOptions,
        autoFill: Bool
    ) async throws -> GetPublicKeyResponse {
        await cancel()
        
        let controller = await GetController()
        authorizer = controller
        return try await controller.performRequests(publicKey: options, autoFill: autoFill)
    }
    
    /**
     Cancels the current credential flow, if one is active.
     
     This is called automatically before starting a new flow to ensure only
     one request is managed at a time.
     */
    private func cancel() async {
       await authorizer?.cancel()
    }
}
