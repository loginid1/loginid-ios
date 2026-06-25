//
//  CryptoUtils.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-11.
//

import Foundation
import CryptoKit

/// A utility structure for performing cryptographic operations.
struct CryptoUtils {

    /// Generates a new ES256 (P-256 curve) key pair for signing operations.
    ///
    /// - Returns: A `KeyPair` object containing both private and public keys.
    static public func generateES256KeyPair() -> KeyPair {
        let privateKey = P256.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        return KeyPair(privateKey: privateKey, publicKey: publicKey)
    }
    
    /// Encodes an encodable value into a Base64URL-encoded JSON string.
    ///
    /// - Parameter value: The encodable value to be serialized and encoded.
    /// - Returns: A Base64URL-encoded string representation of the JSON data.
    static public func base64URLEncode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let jsonData = try encoder.encode(value)
        return jsonData.base64URLEncodedString()
    }
}
