//
//  PasskeyAssertionResponse.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-06-23.
//

import LoginIDCore

/// Represents the result of a passkey assertion.
public struct PasskeyAssertionResponse: Sendable, Codable, Hashable {
    /// Base64URL-encoded authenticator data bytes.
    public let authenticatorData: String
    
    /// Base64URL-encoded UTF-8 JSON bytes representing the client data.
    public let clientDataJSON: String
    
    /// Base64URL-encoded credential ID bytes.
    public let credentialId: String
    
    /// Base64URL-encoded signature bytes returned by the authenticator.
    public let signature: String
    
    /// User handle returned from the authenticator.
    public let userHandle: String?
    
    /**
     Initializes a `PasskeyAssertionResponse` from an auto-generated `AuthenticatorAssertionResponse`.
     - Parameter response: The auto-generated response object.
     */
    internal init(from response: AuthenticatorAssertionResponse) {
        self.authenticatorData = response.authenticatorData
        self.clientDataJSON = response.clientDataJSON
        self.credentialId = response.credentialId
        self.signature = response.signature
        self.userHandle = response.userHandle
    }
}
