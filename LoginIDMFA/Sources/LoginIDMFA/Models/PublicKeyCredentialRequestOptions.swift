//
//  PublicKeyCredentialRequestOptions.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

struct PublicKeyCredentialRequestOptions: Decodable {
    struct PubKeyCredentialDescriptorPubKeyCredentialDescriptor: Decodable {
        let id: String?
    }

    let rpId: String?
    let challenge: String?
    let allowCredentials: [PubKeyCredentialDescriptorPubKeyCredentialDescriptor]?

    var isValid: Bool {
        rpId?.isEmpty == false &&
        challenge?.isEmpty == false &&
        allowCredentials != nil
    }
}
