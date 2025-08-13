//
//  CreateController.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import AuthenticationServices

class CreateController: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {
    private var createContinuation: CheckedContinuation<CreatePublicKeyResponse, Error>?

    public func performRequests(
        publicKey: PublicKeyCredentialCreationOptions
    ) async throws
        -> CreatePublicKeyResponse {
        return try await withCheckedThrowingContinuation { continuation in
            self.createContinuation = continuation

            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                relyingPartyIdentifier: publicKey.rp?.id ?? ""
            )

            let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(
                challenge: publicKey.challenge?.base64URLDecode() ?? Data(),
                name: publicKey.user?.name ?? "",
                userID: Data(publicKey.user?.id?.utf8 ?? "".utf8)
            )

            if let excludeCredentials = publicKey.excludeCredentials {
                var excludeCredentialRequest: [ASAuthorizationPlatformPublicKeyCredentialDescriptor] = []

                for credential in excludeCredentials {
                    let credentialId = credential.id?.base64URLDecode() ?? Data()
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
        }
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        createContinuation?.resume(throwing: error)
        createContinuation = nil
    }

    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let credential as ASAuthorizationPublicKeyCredentialRegistration:
            let response = CreatePublicKeyResponse(
                id: credential.credentialID.base64EncodedData(),
                rawId: credential.credentialID.base64EncodedData(),
                clientDataJSON: credential.rawClientDataJSON.base64EncodedData(),
                attestationObject: credential.rawAttestationObject!.base64EncodedData()
            )
            createContinuation?.resume(returning: response)
        default:
            let error = LoginIDError(msgCode: "invalid_response", msg: "Invalid create credential")
            createContinuation?.resume(throwing: error)
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
