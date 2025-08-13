//
//  GetPublicKeyResponse.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

struct GetPublicKeyResponse {
    public let id: String
    public let rawId: String
    public let clientDataJSON: String
    public let authenticatorData: String
    public let signature: String
    public let userHandle: String

    init(
        id: Data,
        rawId: Data,
        clientDataJSON: Data,
        authenticatorData: Data,
        signature: Data,
        userHandle: Data
    ) {
        self.id = id.base64URLEncodedString()
        self.rawId = rawId.base64URLEncodedString()
        self.clientDataJSON = clientDataJSON.base64URLEncodedString()
        self.authenticatorData = authenticatorData.base64URLEncodedString()
        self.signature = signature.base64URLEncodedString()
        self.userHandle = userHandle.base64URLEncodedString()
    }
}
