//
//  GetController.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import AuthenticationServices

class GetController: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {
    private var getContinuation: CheckedContinuation<GetPublicKeyResponse, Error>?

    public func performRequests(publicKey: PublicKeyCredentialRequestOptions) async throws -> GetPublicKeyResponse {
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
            authController.performRequests()
        }
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        getContinuation?.resume(throwing: error)
        getContinuation = nil
    }

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

    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        return UIWindow()
    }
}
