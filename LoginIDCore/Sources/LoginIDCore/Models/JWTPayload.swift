//
//  JWTPayload.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-11.
//

import Foundation

/// A decoded JSON Web Token (JWT) payload containing the subject's identifier.
///
/// Conforms to `Codable` for easy encoding/decoding from JSON.
struct JWTPayload: Codable {
    /// Expiration date of the JWT.
    let exp: Int
    
    public init() {
        // 5 min exp
        let nowInSeconds = Int(Date().timeIntervalSince1970) + 300
        self.exp = nowInSeconds
    }
}
