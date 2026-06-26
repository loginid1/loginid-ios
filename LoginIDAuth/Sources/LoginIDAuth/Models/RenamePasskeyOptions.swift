//
//  RenamePasskeyOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-26.
//

import Foundation

/// Options for renaming a passkey.
public struct RenamePasskeyOptions {
    /// An optional authorization token for the request.
    /// If not provided, the SDK will use a stored token if available.
    public let authzToken: String?
    
    /// Initializes options for renaming a passkey.
    /// - Parameter authzToken: An optional authorization token.
    public init(authzToken: String? = nil) {
        self.authzToken = authzToken
    }
}
