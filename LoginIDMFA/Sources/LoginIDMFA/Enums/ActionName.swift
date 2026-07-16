//
//  ActionType.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-07-15.
//

import LoginIDCore

/// Represents the type of MFA (Multi-Factor Authentication) action to be performed.
public enum ActionName: String, Sendable, Codable, CaseIterable {
    /// Register a new passkey.
    case passkeyReg = "passkey:reg"
    
    /// Authenticate with an existing passkey.
    case passkeyAuth = "passkey:auth"
    
    /// Confirm a transaction with a passkey.
    case passkeyTx = "passkey:tx"
    
    /// Request an OTP (One-Time Password) via email.
    case otpEmail = "otp:email"
    
    /// Request an OTP (One-Time Password) via SMS.
    case otpSms = "otp:sms"
    
    /// Verify an OTP (One-Time Password) code.
    case otpVerify = "otp:verify"
    
    /// Perform authentication via an external third-party provider.
    case external = "external"
    
    internal func toCoreAction() -> MfaActionAction.Name {
        return MfaActionAction.Name(rawValue: self.rawValue)!
    }
    
    internal init(from coreAction: MfaActionAction.Name) {
        self.init(rawValue: coreAction.rawValue)!
    }
}
