//
//  TrustSet.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-06-23.
//

import Foundation
import LoginIDCore

/// A set of checkout trust tokens.
public struct TrustSet: Codable, Sendable {
    /// The merchant trust ID.
    let merchantTrustId: String?

    /// The wallet trust ID.
    let walletTrustId: String?

    /// Creates a `TrustSet` instance from JSON data.
    /// - Parameter data: The JSON data to decode.
    /// - Throws: An error if decoding fails.
    /// - Returns: A decoded `TrustSet` instance.
    static func fromJSON(_ data: Data) throws -> TrustSet {
        let decoder = JSONCoding.decoder()
        return try decoder.decode(TrustSet.self, from: data)
    }

    /// Encodes the `TrustSet` instance into JSON data.
    /// - Throws: An error if encoding fails.
    /// - Returns: Encoded JSON data.
    func jsonData() throws -> Data {
        let encoder = JSONCoding.encoder()
        return try encoder.encode(self)
    }
}
