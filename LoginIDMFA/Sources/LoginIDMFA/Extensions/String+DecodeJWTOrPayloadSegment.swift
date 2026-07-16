//
//  String+DecodeJWTOrPayloadSegment.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-14.
//

import Foundation

/// Decodes a JWT payload segment or a raw Base64URL-encoded string into `Data`.
///
/// If the string appears to be a JWT (`header.payload.signature`), the method
/// extracts and decodes only the payload segment. Otherwise, it decodes the
/// entire string as Base64URL.
///
/// - Returns: The decoded `Data`, or `nil` if the string is not valid Base64URL.
internal extension String {
    func decodeJWTOrPayloadSegment() -> Data? {
        let segment: String
        if let candidate = self.split(separator: ".").dropFirst().first {
            segment = String(candidate)
        } else {
            segment = self
        }
        return segment.base64URLDecode()
    }
}
