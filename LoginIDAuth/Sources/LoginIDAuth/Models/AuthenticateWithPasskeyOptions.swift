//
//  AuthenticateWithPasskeyOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-26.
//

import LoginIDCore

public struct AuthenticateWithPasskeyOptions {
    /// The type of username validation to be used.
    /// Defaults to `.other` and is omitted from the payload when `.other`.
    public let usernameType: UsernameType
    
    /// When true it will enable passkey keyboard autofill suggestions. Username does not need to be set.
    public let autofill: Bool?

    public init(
        usernameType: UsernameType = .other,
        autoFill: Bool? = nil
    ) {
        self.usernameType = usernameType
        self.autofill = autoFill
    }
    
    init(
        options: AuthenticateWithPasskeyOptions? = nil,
    ) {
        self.autofill = true
        self.usernameType = options?.usernameType ?? .other
    }
}
