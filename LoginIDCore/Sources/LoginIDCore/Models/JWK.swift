//
//  JWK.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-11.
//

/// A JSON Web Key (JWK) representing an elliptic curve public key.
///
/// Conforms to `Codable` for parsing from JSON.
struct JWK: Codable {
    /// Key type (e.g., `"EC"` for Elliptic Curve).
    let kty: String
    
    /// The curve used (e.g., `"P-256"`).
    let crv: String
    
    /// The x-coordinate for the public key point, Base64URL encoded.
    let x: String
    
    /// The y-coordinate for the public key point, Base64URL encoded.
    let y: String
}
