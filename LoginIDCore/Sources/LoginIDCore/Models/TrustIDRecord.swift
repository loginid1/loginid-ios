//
//  TrustIDRecord.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-18.
//

import Foundation

/// Represents a stored Trust ID record in the trust store database.
struct TrustIDRecord: Codable {
    /// Unique identifier for the Trust ID.
    let id: String

    /// App ID associated with this store, for user-specific records.
    let appId: String

    /// Username associated with the Trust ID, for user-specific records.
    let username: String

    /// The cryptographic key pair associated with the Trust ID.
    let keyPair: Data

    /// Timestamp of when this record was last used, to identify the latest active Trust ID used.
    var lastUsedAt: Date
}
