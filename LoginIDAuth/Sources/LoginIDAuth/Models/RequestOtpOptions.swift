//
//  RequestOtpOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import Foundation

/// Options for requesting a one-time password (OTP).
public struct RequestOtpOptions {
    /// An optional authorization token for the request.
    /// If not provided, the SDK will use a stored token if available.
    public let authzToken: String?
    
    /// Initializes options for requesting an OTP.
    /// - Parameter authzToken: An optional authorization token.
    public init(authzToken: String? = nil) {
        self.authzToken = authzToken
    }
}
