//
//  String+DecodeJWTOrPayloadSegment.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

extension String {
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
