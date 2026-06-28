//
//  RequestAndSendOtpOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import LoginIDCore

/// Options for requesting and sending a one-time password (OTP).
public struct RequestAndSendOtpOptions {
    /// The type of username validation to be used.
    /// Defaults to `.other` and is omitted from the payload when `.other`.
    public let usernameType: UsernameType
    
    /// Initializes options for requesting and sending an OTP.
    /// - Parameter usernameType: The type of username validation to use. Defaults to `.other`.
    public init(usernameType: UsernameType = .other) {
        self.usernameType = usernameType
    }
}
