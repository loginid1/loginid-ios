//
//  PublicKeyCredentialCreationOptions.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

struct PublicKeyCredentialCreationOptions: Decodable {
    struct RelyingParty: Decodable { let id: String? }
    struct User: Decodable {
        let id: String?
        let name: String?
    }
    struct PubKeyCredentialDescriptorPubKeyCredentialDescriptor: Decodable {
        let id: String?
    }

    let rp: RelyingParty?
    let challenge: String?
    let user: User?
    let excludeCredentials: [PubKeyCredentialDescriptorPubKeyCredentialDescriptor]?
    
    var isValid: Bool {
        rp?.id?.isEmpty == false &&
        challenge?.isEmpty == false &&
        (user?.id?.isEmpty == false)
    }
}
