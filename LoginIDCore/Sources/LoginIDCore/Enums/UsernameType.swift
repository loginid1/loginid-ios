//
//  UsernameType.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-06-22.
//

/// Defines how LoginID validates and interprets a username value.
public enum UsernameType: String, Sendable, Codable {
    /// No predefined username format is enforced.
    ///
    /// Usernames must be 5–128 characters long and may contain
    /// letters, digits, `_`, `-`, `+`, `/`, and `=`.
    case other = "other"

    /// The username must be a valid email address.
    ///
    /// Email addresses are validated according to RFC 5322 rules.
    case email = "email"

    /// The username must be a valid phone number.
    ///
    /// Phone numbers may be provided in E.164 format or in supported
    /// human-friendly formats that can be normalized to E.164.
    case phone = "phone"
}
