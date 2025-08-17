//
//  GetController.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import AuthenticationServices
import LoginIDCore

/// Handles the assertion of passkeys on iOS,
/// using the `ASAuthorizationPlatformPublicKeyCredentialProvider` API.
/// Wraps delegate callbacks in Swift's async/await model with `CheckedContinuation`.
class GetController: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding, KeyAuthorizer {
    /// Continuation used to resume execution after the authorization request completes.
    private var getContinuation: CheckedContinuation<GetPublicKeyResponse, Error>?
    
    /// Authorization controller responsible for managing the lifecycle of the passkey creation request.
    private var authController: ASAuthorizationController?

    /**
     Initiates a passkey assertion request.
     
     - Parameters:
       - publicKey: The `PublicKeyCredentialRequestOptions` containing the challenge,
         relying party ID, and allowed credentials for assertion.
       - autoFill: If `true`, performs an AutoFill-assisted request; otherwise, performs a standard request.
     
     - Returns: A `GetPublicKeyResponse` with the credential's ID, raw ID, client data,
       authenticator data, signature, and user handle.
     
     - Throws:
       - Any `Error` encountered during the request.
       - `LoginIDError` if the response is invalid.
     */
    public func performRequests(
        publicKey: PublicKeyCredentialRequestOptions,
        autoFill: Bool = false,
    ) async throws -> GetPublicKeyResponse {
        return try await withCheckedThrowingContinuation { continuation in
            self.getContinuation = continuation

            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                relyingPartyIdentifier: publicKey.rpId ?? ""
            )
            let platformKeyRequest = platformProvider.createCredentialAssertionRequest(
                challenge: publicKey.challenge?.base64URLDecode() ?? Data()
            )

            platformKeyRequest.allowedCredentials = []

            for credential in publicKey.allowCredentials ?? [] {
                let credentialId = credential.id?.base64URLDecode() ?? Data()
                let credentialDescriptor =
                    ASAuthorizationPlatformPublicKeyCredentialDescriptor(
                        credentialID: credentialId
                    )
                platformKeyRequest.allowedCredentials.append(credentialDescriptor)
            }

            let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])

            authController.delegate = self
            authController.presentationContextProvider = self
            
            if autoFill {
                authController.performAutoFillAssistedRequests()
            } else {
                authController.performRequests()
            }
            
            self.authController = authController
        }
    }

    /// Called when the authorization request fails.
    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        getContinuation?.resume(throwing: error)
        getContinuation = nil
    }

    /// Called when the authorization request completes successfully.
    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let credential as ASAuthorizationPublicKeyCredentialAssertion:
            let response = GetPublicKeyResponse(
                id: credential.credentialID,
                rawId: credential.credentialID,
                clientDataJSON: credential.rawClientDataJSON,
                authenticatorData: credential.rawAuthenticatorData,
                signature: credential.signature,
                userHandle: credential.userID
            )
            getContinuation?.resume(returning: response)
        default:
            let error = LoginIDError(msgCode: "invalid_response", msg: "Invalid create credential")
            getContinuation?.resume(throwing: error)
        }
    }

    /*
    Provides the presentation anchor (window) used for the passkey creation UI.
    
    - Returns: The first available window in the connected scenes, or a new `UIWindow` if none found.
    */
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
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
    func cancel() {
        authController?.cancel()
    }
}
