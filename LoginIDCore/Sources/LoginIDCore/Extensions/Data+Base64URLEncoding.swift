//
//  Data+Base64URLEncoding.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-11.
//

import Foundation

public extension Data {
    /// Encodes the data as a Base64URL string (RFC 7515-compliant).
    ///
    /// - Returns: A Base64URL-encoded string.
    func base64URLEncodedString() -> String {
        let base64 = self.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
