//
//  SessionInfo.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-28.
//

/// Provides information about the current authenticated session.
public struct SessionInfo {
    /// The authenticated user's username.
    public let username: String

    /// The subject identifier for the authenticated user.
    public let id: String
    
    /// Relying party ID used typically used for passkey authentication to confirm the user has signed in under the specific domain.
    public let rpId: String
    
    /// Initializes session information from a decoded LoginID access token.
    /// - Parameter loginIdToken: The decoded access token.
    public init(loginIdToken: LoginIDJWTAccess) {
        self.username = loginIdToken.username
        self.id = loginIdToken.sub
        self.rpId = loginIdToken.rpId
    }
}
