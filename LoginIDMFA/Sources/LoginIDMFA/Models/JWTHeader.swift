//
//  JWTHeader.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

/// The header of a JSON Web Token (JWT), including the signing algorithm and public key.
///
/// Conforms to `Codable` for parsing from JSON.
struct JWTHeader: Codable {
    /// The algorithm used for signing the JWT (e.g., `"ES256"`).
    let alg: String
    
    /// The JSON Web Key (JWK) containing the public key information.
    let jwk: JWK
}
