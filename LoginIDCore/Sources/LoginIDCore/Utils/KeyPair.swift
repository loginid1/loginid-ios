//
//  KeyPair.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-11.
//

import Foundation
import CryptoKit

/// A container for an ES256 (P-256) private/public key pair, including a UUID-based identifier.
struct KeyPair {
    /// The private signing key.
    let privateKey: P256.Signing.PrivateKey
    
    /// The corresponding public signing key.
    let publicKey: P256.Signing.PublicKey
    
    /// Reconstructs a `KeyPair` from binary data.
    ///
    /// - Parameter data: The binary-encoded key pair.
    /// - Returns: A reconstructed `KeyPair` object.
    static public func fromData(_ data: Data) throws -> KeyPair {
        var offset = 0
        
        guard data.count >= 4 else {
            throw CryptoError.invalidPublicKeyFormat
        }
        
        // Extract privateKey
        let privateKeyLengthData = data[offset..<offset+4]
        offset += 4
        let privateKeyLength = UInt32(bigEndian: privateKeyLengthData.withUnsafeBytes {
            $0.load(as: UInt32.self)
        })
        let privateKeyData = data[offset..<offset+Int(privateKeyLength)]
        offset += Int(privateKeyLength)
        
        // Extract publicKey
        let publicKeyLengthData = data[offset..<offset+4]
        offset += 4
        let publicKeyLength = UInt32(bigEndian: publicKeyLengthData.withUnsafeBytes {
            $0.load(as: UInt32.self)
        })
        let publicKeyData = data[offset..<offset+Int(publicKeyLength)]
        
        let privateKey = try P256.Signing.PrivateKey(rawRepresentation: privateKeyData)
        let publicKey = try P256.Signing.PublicKey(rawRepresentation: publicKeyData)
        
        return KeyPair(privateKey: privateKey, publicKey: publicKey)
    }
    
    /// Serializes the key pair into a binary data format.
    ///
    /// - Returns: A binary `Data` object representing the key pair.
    public func toData() throws -> Data {
        let privateKeyData = privateKey.rawRepresentation
        let publicKeyData = publicKey.rawRepresentation
        
        var data = Data()
        
        var privateKeyLength = UInt32(privateKeyData.count).bigEndian
        data.append(Data(bytes: &privateKeyLength, count: 4))
        data.append(privateKeyData)
        
        var publicKeyLength = UInt32(publicKeyData.count).bigEndian
        data.append(Data(bytes: &publicKeyLength, count: 4))
        data.append(publicKeyData)
        
        return data
    }
    
    /// Exports the public key in JWK (JSON Web Key) format.
    ///
    /// - Returns: A `JWK` object representing the public key.
    public func exportPublicKeyJwk() throws -> JWK {
        let rawPublicKey = self.publicKey.x963Representation
        
        guard rawPublicKey.count == 65, rawPublicKey.first == 0x04 else {
            throw CryptoError.invalidPublicKeyFormat
        }

        let xData = rawPublicKey[1..<33]
        let yData = rawPublicKey[33..<65]

        let x = xData.base64URLEncodedString()
        let y = yData.base64URLEncodedString()

        return JWK(
            kty: "EC",
            crv: "P-256",
            x: x,
            y: y
        )
    }
    
    /// Signs the given string using the private key and returns a Base64URL-encoded signature.
    ///
    /// - Parameter data: The string to be signed.
    /// - Returns: A Base64URL-encoded ES256 signature.
    public func signWithES256PrivateKey(_ data: String) throws -> String {
        guard let messageData = data.data(using: .utf8) else {
            throw CryptoError.invalidUTF8Encoding
        }

        let signature = try self.privateKey.signature(for: messageData)
        let rawSignature = signature.rawRepresentation
        
        return rawSignature.base64URLEncodedString()
    }
}
