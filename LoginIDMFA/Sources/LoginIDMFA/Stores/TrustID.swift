//
//  TrustID.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

/// Handles the lifecycle and signing of a Trust ID
/// stored securely in the Keychain.
public protocol TrustIDManaging {
    /// Removes the Trust ID and its key pair from the Keychain.
    func deleteTrustId()
    
    /// Signs and returns a Trust ID.
    ///
    /// Reuses the existing key pair if available; otherwise,
    /// generates and stores a new ES256 key pair.
    ///
    /// - Returns: A signed JWT string.
    /// - Throws: If key access or signing fails.
    func signWithTrustId() throws -> String
}

/// A helper type that manages the lifecycle of a wallet identity using a cryptographic key stored in the Keychain.
final public class TrustID : TrustIDManaging {
    /// Builds the unique key used to store the wallet identity in the Keychain.
    ///
    /// - Returns: A Keychain-safe string based on the app ID.
    private func storeKey() -> String {
        return "LOGINID_TRUST_ID"
    }
    
    /// Deletes the stored wallet identity from the Keychain.
    public func deleteTrustId() {
        _ = KeychainManager.removeItem(key: storeKey())
    }
    
    /// Signs a new or existing Trust ID using its associated private key.
    ///
    /// If a key pair is already stored, it is reused. Otherwise, a new key pair is generated and stored.
    ///
    /// - Returns: A signed JWT representing the trust ID.
    public func signWithTrustId() throws -> String {
        if let data = KeychainManager.getItem(key: storeKey()) {
            let keyPair = try KeyPair.fromData(data)
            let payload = toTrustIdPayload()
            let trustId = try signJwtWithJwk(payload: payload, keyPair: keyPair)
            return trustId
        }
        
        return try setTrustId()
    }
    
    /// Generates a new Trust ID, signs it, and persists it to the Keychain.
    ///
    /// - Returns: A signed JWT representing the new trust ID.
    private func setTrustId() throws -> String {
        let keyPair = CryptoUtils.generateES256KeyPair()
        let payload = toTrustIdPayload()
        let trustId = try signJwtWithJwk(payload: payload, keyPair: keyPair)
        
        let keyPairData = try keyPair.toData()
        _ = KeychainManager.setItem(key: storeKey(), data: keyPairData)
        
        return trustId
    }
    
    /// Constructs a payload object for the trust ID JWT.
    ///
    /// - Parameters:
    ///   - appId: The application ID.
    ///   - id: The identifier for the key pair. If `nil`, a new UUID is generated.
    /// - Returns: A `JWTPayload` containing the ID.
    private func toTrustIdPayload() -> JWTPayload {
        return JWTPayload()
    }
    
    /// Signs a JWT with a given payload and key pair using the ES256 algorithm.
    ///
    /// - Parameters:
    ///   - payload: The payload to encode and sign.
    ///   - keyPair: The key pair to use for signing.
    /// - Returns: A fully signed JWT string.
    private func signJwtWithJwk(payload: JWTPayload, keyPair: KeyPair) throws -> String {
        let jwk = try keyPair.exportPublicKeyJwk()
        let header = JWTHeader(alg: "ES256", jwk: jwk)
        
        let encodedHeader = try CryptoUtils.base64URLEncode(header)
        let encodedPayload = try CryptoUtils.base64URLEncode(payload)
        let unsignedToken = encodedHeader + "." + encodedPayload
        let signature = try keyPair.signWithES256PrivateKey(unsignedToken)
        
        return unsignedToken + "." + signature
    }
}
