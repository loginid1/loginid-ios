//
//  ConfirmTransactionOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-26.
//

import LoginIDCore

/// Options for configuring a transaction confirmation request.
public struct ConfirmTransactionOptions {
    /// A unique nonce to ensure the transaction's integrity and prevent replay attacks
    /// If not provided, a new UUID will be generated.
    public let nonce: String?
    
    /// The type of transaction payload, such as `raw` or a custom format.
    /// Defaults to `raw` if not specified.
    public let txType: String?

    /// Creates a new set of options for transaction confirmation.
    ///
    /// - Parameters:
    ///   - nonce: An optional random string to prevent replay attacks.
    ///   - txType: An optional string specifying the transaction payload type. Defaults to `raw`.
    public init(
        nonce: String? = nil,
        txType: String? = nil
    ) {
        self.nonce = nonce
        self.txType = txType
    }
}
