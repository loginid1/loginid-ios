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
    
    /// A unique identifier used to trace and correlate all events associated with a single authentication interaction.
    /// If you don’t provide this, the server may generate one automatically.
    public let traceId: String?

    public init(
        usernameType: UsernameType = .other,
        autoFill: Bool? = nil,
        traceId: String? = nil
    ) {
        self.usernameType = usernameType
        self.autofill = autoFill
        self.traceId = traceId
    }
    
    internal init(
        options: AuthenticateWithPasskeyOptions? = nil,
    ) {
        self.autofill = true
        self.usernameType = options?.usernameType ?? .other
        self.traceId = options?.traceId
    }
}
