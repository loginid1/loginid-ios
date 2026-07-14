//
//  AuthResult.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-24.
//

import LoginIDCore

/// The result of a successful authentication attempt using either a passkey
/// or a one-time password (OTP).
public struct AuthResult {
    /// A short-lived authorization token that can be used to access protected
    /// resources for the authenticated user, such as listing, renaming, or
    /// deleting passkeys.
    ///
    /// This value is `nil` when authentication falls back to an alternative
    /// authentication method. /// 
    public let token: String?
    
    /// The authentication methods that can be used as a fallback when passkey
    /// authentication is not available or recommended.
    public let fallbackOptions: [String]?
    
    /// A Boolean value indicating whether the user was successfully authenticated.
    ///
    /// If `false`, inspect ``fallbackOptions`` to determine the available
    /// alternative authentication methods.
    public let isAuthenticated: Bool
    
    /// A Boolean value indicating whether the user was successfully authenticated.
    ///
    /// If `false`, inspect ``fallbackOptions`` to determine the available
    /// alternative authentication methods.
    public let isFallback: Bool
    
    /// The unique identifier of the authenticated user.
    ///
    /// This value is `nil` when authentication was not completed.
    public let userId: String?
    
    /// The identifier of the passkey used to authenticate the user.
    ///
    /// This value is `nil` when authentication did not use a passkey or was
    /// not completed.
    public let passkeyId: String?
    
    /// An identifier for the device that participated in the authentication
    /// process.
    ///
    /// This identifier can be used to determine whether future authentication
    /// methods are supported on the current device.
    public let deviceId: String?

    internal init(result: JWT) {
        token = result.jwtAccess
        fallbackOptions = nil
        isAuthenticated = true
        isFallback = false
        userId = result.userId
        passkeyId = result.passkeyId
        deviceId = result.deviceId
    }

    internal init(fallbackOptions: [String]) {
        token = nil
        self.fallbackOptions = fallbackOptions
        isAuthenticated = false
        isFallback = !fallbackOptions.isEmpty
        userId = nil
        deviceId = nil
        passkeyId = nil
    }
}
