//
//  OTPResult.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import LoginIDCore

/// The result of a successful one-time password (OTP) request.
public struct OTPResult {
    /// The generated one-time password.
    public let code: String
    
    /// The expiration timestamp of the code in RFC3339 format.
    public let expiresAt: String
    
    /// Initializes an `OTPResult` from an `AuthCode` API response.
    /// - Parameter result: The `AuthCode` object from the API.
    internal init(result: AuthCode) {
        self.code = result.code
        self.expiresAt = result.expiresAt
    }
}
