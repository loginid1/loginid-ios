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
        self.id = id.base64EncodedString()
        self.rawId = rawId.base64EncodedString()
        self.clientDataJSON = clientDataJSON.base64EncodedString()
        self.authenticatorData = authenticatorData.base64EncodedString()
        self.signature = signature.base64EncodedString()
        self.userHandle = userHandle.base64EncodedString()
    }
}
