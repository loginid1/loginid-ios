//
//  PasskeyInfo.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-06-23.
//

import LoginIDCore

/// Represents additional information about a passkey.
public struct PasskeyInfo: Sendable, Codable, Hashable {
    /// AAGUID identifying the passkey provider/authenticator model.
    public let aaguid: String
    
    /// The result of the passkey assertion.
    public let assertionResult: PasskeyAssertionResponse?
    
    /// The result of the passkey creation.
    public let creationResult: PasskeyCreationResult?
    
    /// Internal passkey ID which is used for [passkey management](https://docs.loginid.io/user-scenario/user-profile-management/passkey-management/).
    public let passkeyId: String
    
    /// Base64URL-encoded COSE public key of the passkey's credential.
    public let publicKey: String

    /**
     Initializes `PasskeyInfo` from an auto-generated `AdditionalPasskeyInfo`.
     - Parameter info: The auto-generated info object.
     */
    init(from info: AdditionalPasskeyInfo) {
        self.aaguid = info.aaguid
        self.assertionResult = info.assertionResult.map { PasskeyAssertionResponse(from: $0) }
        self.creationResult = info.creationResult.map { PasskeyCreationResult(from: $0) }
        self.passkeyId = info.passkeyId
        self.publicKey = info.publicKey
    }
}
