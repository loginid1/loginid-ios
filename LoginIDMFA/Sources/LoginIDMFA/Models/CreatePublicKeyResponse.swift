//
//  CreatePublicKeyResponse.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

struct CreatePublicKeyResponse {
    public let id: String
    public let rawId: String
    public let clientDataJSON: String
    public let attestationObject: String

    init(id: Data, rawId: Data, clientDataJSON: Data, attestationObject: Data) {
        self.id = id.base64URLEncodedString()
        self.rawId = rawId.base64URLEncodedString()
        self.clientDataJSON = clientDataJSON.base64URLEncodedString()
        self.attestationObject = attestationObject.base64URLEncodedString()
    }
}
