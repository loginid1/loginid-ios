//
//  ListPasskeysOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-26.
//

import Foundation

/// Options for listing passkeys.
public struct ListPasskeysOptions {
    /// An optional authorization token for the request.
    /// If not provided, the SDK will use a stored token if available.
    public let authzToken: String?
    
    /// Initializes options for listing passkeys.
    /// - Parameter authzToken: An optional authorization token.
    public init(authzToken: String? = nil) {
        self.authzToken = authzToken
    }
}
