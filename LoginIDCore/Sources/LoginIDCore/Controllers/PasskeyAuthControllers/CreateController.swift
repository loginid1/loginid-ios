//
//  CreateController.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import AuthenticationServices

/// Handles the creation of a passkeys on iOS,
/// using the `ASAuthorizationPlatformPublicKeyCredentialProvider` API.
/// This class wraps the delegate callbacks in Swift's async/await model
/// using `CheckedContinuation`.
public class CreateController: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding, KeyAuthorizer {
    /// Continuation used to resume execution after the authorization request completes.
    private var createContinuation: CheckedContinuation<CreatePublicKeyResponse, Error>?
    
    /// Authorization controller responsible for managing the lifecycle of the passkey creation request.
    private var authController: ASAuthorizationController?

    /**
     Initiates a passkey creation request.
     
     - Parameter publicKey: The `PublicKeyCredentialCreationOptions` containing challenge,
       relying party, and user information required for credential creation.
     
     - Returns: A `CreatePublicKeyResponse` containing the credential's ID, raw ID,
       client data, and attestation object.
     
     - Throws:
       - Any `Error` encountered during the request.
       - `LoginIDError` if the response is invalid.
     
     - Important: This method must be called from a context that allows presentation of
       an authentication UI (typically the main thread / main actor).
     */
    public func performRequests(
        publicKey: PublicKeyCredentialCreationOptions
    ) async throws
        -> CreatePublicKeyResponse {
        return try await withCheckedThrowingContinuation { continuation in
            self.createContinuation = continuation

            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                relyingPartyIdentifier: publicKey.rp.id ?? ""
            )

            let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(
                challenge: publicKey.challenge.base64URLDecode() ?? Data(),
                name: publicKey.user.name ?? "",
                userID: Data(publicKey.user.id.utf8 ?? "".utf8)
            )

            if let excludeCredentials = publicKey.excludeCredentials {
                var excludeCredentialRequest: [ASAuthorizationPlatformPublicKeyCredentialDescriptor] = []

                for credential in excludeCredentials {
                    let credentialId = credential.id.base64URLDecode() ?? Data()
                    let credentialDescriptor =
                        ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialId)
                    excludeCredentialRequest.append(credentialDescriptor)
                }

                if #available(iOS 17.4, *) {
                    platformKeyRequest.excludedCredentials = excludeCredentialRequest
                }
            }

            let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])

            authController.delegate = self
            authController.presentationContextProvider = self
            authController.performRequests()
            
            self.authController = authController
        }
    }

    /// Called when the authorization request fails.
    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        createContinuation?.resume(throwing: error)
        createContinuation = nil
    }

    /// Called when the authorization request completes successfully.
    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let credential as ASAuthorizationPublicKeyCredentialRegistration:
            let response = CreatePublicKeyResponse(
                id: credential.credentialID,
                rawId: credential.credentialID,
                clientDataJSON: credential.rawClientDataJSON,
                attestationObject: credential.rawAttestationObject!
            )
            createContinuation?.resume(returning: response)
        default:
            let error = LoginIDError(msgCode: "invalid_response", msg: "Invalid create credential")
            createContinuation?.resume(throwing: error)
        }
    }

    /**
     Provides the presentation anchor (window) used for the passkey creation UI.
     
     - Returns: The first available window in the connected scenes, or a new `UIWindow` if none found.
     */
    public func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        return UIWindow()
    }
    
    /**
     Cancels the current passkey creation request, if any is in progress.
     
     - Important: This will dismiss any system UI related to credential creation
       and terminate the current authorization flow.
     */
    public func cancel() {
        authController?.cancel()
    }
 }
