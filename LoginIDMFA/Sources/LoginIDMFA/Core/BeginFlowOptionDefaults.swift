//
//  BeginFlowOptionDefaults.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDAPIClient

/// Provides defaulted accessors for `BeginFlowOptions`,
/// falling back to sensible values (such as the provided username)
/// when options are missing or incomplete.
final class BeginFlowOptionDefaults {
    /// `beginFlow` options sent in by the user.
    private let options: BeginFlowOptions?
    
    /// User's username.
    private let username: String

    /**
     Creates a new defaults helper for MFA flow options.
     
     - Parameters:
       - username: The username to fall back to if `displayName` is not provided.
       - options: Optional `BeginFlowOptions` from which to read values.
     */
    public init(username: String, options: BeginFlowOptions?) {
        self.username = username
        self.options = options
    }
    
    /// The display name to use, falling back to `username` if not provided or empty.
    var displayName: String {
        return options?.displayName?.isEmpty == false ? options!.displayName! : username
    }
    
    /// The type of username validation to use, defaulting to `.other`.
    var usernameType: User.UsernameType {
        return options?.usernameType ?? .other
    }
    
    /// The transaction payload to use, if provided.
    var txPayload: String? {
        return options?.txPayload
    }
    
    /// The checkout opaque session, if provided.
    var checkoutId: String? {
        return options?.checkoutId
    }
    
    /// The trace identifier for correlating MFA events, if provided.
    var traceId: String? {
        return options?.traceId
    }
    
    /// A `User` object constructed from the resolved defaults.
    var user: User {
        return User(
            displayName: displayName,
            username: username,
            usernameType: usernameType,
        )
    }
}
