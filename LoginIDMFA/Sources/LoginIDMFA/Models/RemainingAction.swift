//
//  RemainingFactor.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import LoginIDCore

/// Represents an individual MFA (Multi-Factor Authentication) factor that the user must complete.
public struct RemainingAction: Sendable {
    
    /// The type of the MFA factor, such as passkey or OTP via email or SMS.
    ///
    /// Use this value in `performAction` to initiate the factor.
    public let type: ActionName
    
    /// A user-friendly label for the factor, providing context on how it should be used.
    public let label: String
    
    /// A description of the MFA factor, explaining its purpose or instructions for completion.
    public let description: String?
    
    /// A unique token for authentication, useful for advanced MFA flows across multiple devices.
    ///
    /// This is available for the following MFA factor:
    /// - passkey
    ///
    /// Example: To authenticate or add a passkey on another device, pass this value
    /// along with the session token to continue the MFA process.
    public let value: String?
    
    /// A list of available options for the MFA factor, if applicable.
    ///
    /// Supported for the following MFA factors:
    /// - otp:email
    /// - otp:sms
    ///
    /// Typically includes valid email addresses or phone numbers for OTP delivery.
    public let options: [String]?
}
