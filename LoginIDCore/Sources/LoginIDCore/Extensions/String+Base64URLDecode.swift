//
//  String+Base64URLDecode.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

public extension String {
    /// Decodes a Base64URL-encoded string into `Data`.
    ///
    /// This method replaces URL-safe characters (`-` → `+`, `_` → `/`),
    /// then pads the string to a multiple of 4 characters before decoding.
    ///
    /// - Returns: The decoded `Data`, or `nil` if the string is not valid Base64URL.
    func base64URLDecode() -> Data? {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Pad to multiple of 4
        let remainder = base64.count % 4
        if remainder != 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }
        return Data(base64Encoded: base64)
    }
}
