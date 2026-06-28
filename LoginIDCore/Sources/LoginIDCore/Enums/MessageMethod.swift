//
//  MessageMethod.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-28.
//

/// The channel through which to send a one-time password (OTP).
public enum MessageMethod: String, Sendable, Codable {
    /// Send the OTP via email.
    case email
    
    /// Send the OTP via SMS.
    case sms
}
