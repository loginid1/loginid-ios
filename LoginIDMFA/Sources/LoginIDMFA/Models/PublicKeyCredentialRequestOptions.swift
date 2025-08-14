//
//  PublicKeyCredentialRequestOptions.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

/// Represents the options for requesting (asserting) a passkey public key credential,
/// as defined in the WebAuthn specification.
///
/// Conforms to `Decodable` for parsing from JSON.
struct PublicKeyCredentialRequestOptions: Decodable {
    /// Descriptor for a public key credential allowed for assertion.
    struct PubKeyCredentialDescriptorPubKeyCredentialDescriptor: Decodable {
        let id: String?
    }

    /// The relying party identifier for which the credential is scoped.
    let rpId: String?
    
    /// The cryptographic challenge issued by the LoginID.
    let challenge: String?
    
    /// The list of allowed credentials for assertion.
    let allowCredentials: [PubKeyCredentialDescriptorPubKeyCredentialDescriptor]?

    /// Indicates whether the options contain the minimum required fields to be valid.
    var isValid: Bool {
        rpId?.isEmpty == false &&
        challenge?.isEmpty == false &&
        allowCredentials != nil
    }
}
