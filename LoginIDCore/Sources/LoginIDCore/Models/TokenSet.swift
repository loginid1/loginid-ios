//
//  TokenSet.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

/// A collection of authentication tokens returned after a successful login.
public struct TokenSet : Codable {
    /// An authorization token (JWT) confirming successful authentication.
    /// Optional — may be omitted if the `idToken` is not received.
    public let idToken: String?
    
    /// An authorization token (JWT) confirming successful authentication.
    /// Optional — may be omitted if the `accessToken` is not received.
    public let accessToken: String?
    
    /// An authorization token (JWT) confirming successful authentication.
    /// Optional — may be omitted if the `refreshToken` is not received.
    public let refreshToken: String?
    
    /// An authorization token (JWT) confirming successful authentication.
    /// Optional — may be omitted if the `payloadSignature` is not received.
    public let payloadSignature: String?
    
    /// Creates an `TokenSet` instance from JSON data.
    /// - Parameter data: The JSON data to decode.
    /// - Throws: An error if decoding fails.
    /// - Returns: A decoded `TokenSet` instance.
    public static func fromJSON(_ data: Data) throws -> TokenSet {
        let decoder = JSONCoding.decoder()
        return try decoder.decode(TokenSet.self, from: data)
    }
    
    public init(result: Mfa) {
        self.idToken = result.idToken
        self.accessToken = result.accessToken
        self.refreshToken = result.refreshToken
        self.payloadSignature = result.payloadSignature
    }
    
    /**
     Creates a token set from its individual token values.

     - Parameters:
       - idToken: The ID token.
       - accessToken: The access token.
       - refreshToken: The refresh token.
       - payloadSignature: The payload signature.
     */
    public init(
        idToken: String?,
        accessToken: String?,
        refreshToken: String?,
        payloadSignature: String?
    ) {
        self.idToken = idToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.payloadSignature = payloadSignature
    }
    
    /// Encodes the `TokenSet` instance into JSON data.
    /// - Throws: An error if encoding fails.
    /// - Returns: Encoded JSON data.
    public func jsonData() throws -> Data {
        let encoder = JSONCoding.encoder()
        return try encoder.encode(self)
    }
}
