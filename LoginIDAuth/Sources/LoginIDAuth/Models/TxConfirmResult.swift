//
//  TxConfirmResult.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-26.
//

import LoginIDCore

/// The result of a successful transaction confirmation.
public struct TxConfirmResult {
    /// An authorization token that confirms the transaction.
    public let token: String
    
    /// The identifier of the passkey credential used for confirmation.
    public let credentialId: String
    
    /// Optional details about the passkey used for confirmation.
    public let passkey: PasskeyDetails?
    
    /// Initializes a `TxConfirmResult` from a `TxComplete` API response.
    /// - Parameter result: The `TxComplete` object from the API.
    init(result: TxComplete) {
        self.token = result.token
        self.credentialId = result.credentialId
        self.passkey = result.authCred.map(PasskeyDetails.init)
    }
}
