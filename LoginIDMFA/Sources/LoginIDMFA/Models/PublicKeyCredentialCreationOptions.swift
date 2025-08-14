//
//  PublicKeyCredentialCreationOptions.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

/// Represents the options for creating a passkey public key credential,
/// as defined in the WebAuthn specification.
///
/// Conforms to `Decodable` for parsing from JSON.
struct PublicKeyCredentialCreationOptions: Decodable {
    /// Information about the relying party (RP) requesting the credential.
    struct RelyingParty: Decodable { let id: String? }
    
    /// Information about the user account for which the credential is created.
    struct User: Decodable {
        let id: String?
        let name: String?
    }
    
    /// Descriptor for a public key credential to be excluded during creation.
    struct PubKeyCredentialDescriptorPubKeyCredentialDescriptor: Decodable {
        let id: String?
    }

    /// The relying party information.
    let rp: RelyingParty?
    
    /// The cryptographic challenge issued by LoginID.
    let challenge: String?
    
    /// The user information for credential creation.
    let user: User?
    
    /// A list of credentials that should not be created again.
    let excludeCredentials: [PubKeyCredentialDescriptorPubKeyCredentialDescriptor]?
    
    /**
     Creates a new instance, replacing the username in the provided options with a new value.
     
     - Parameters:
       - options: The original credential creation options.
       - username: The new username to set in the `user` field.
     */
    public init(options: PublicKeyCredentialCreationOptions, username: String) {
        self.rp = options.rp
        self.challenge = options.challenge
        
        if let existingUser = options.user {
            self.user = User(
                id: existingUser.id,
                name: username
            )
        } else {
            self.user = nil
        }
        
        self.excludeCredentials = options.excludeCredentials
    }
    
    /// Indicates whether the options contain the minimum required fields to be valid.
    var isValid: Bool {
        rp?.id?.isEmpty == false &&
        challenge?.isEmpty == false &&
        (user?.id?.isEmpty == false)
    }
}
