//
//  SessionManager.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation
import LoginIDCore

/// A protocol defining methods for managing an MFA session's lifecycle.
public protocol SessionManaging: Sendable {
    /**
     Logs the user out of the current session and removes any stored credentials or tokens.
     */
    func logout()

    /**
     Persists a session's token set securely.

     - Parameter tokenSet: The `TokenSet` to store. If `nil`, the method ignores the request.
     */
    func setTokenSet(_ tokenSet: TokenSet?)

    /**
     Returns the authorization token to use for authenticated requests.

     If `authzToken` is provided and non-empty, it is returned directly.
     Otherwise, the stored access token is returned if it exists and has not expired.

     - Parameter authzToken: An optional authorization token supplied by the caller.
     - Returns: A valid authorization token, or `nil` if none is available.
     */
    func getAuthzToken(authzToken: String?) -> String?
    
    /**
     Stores an access token in the current session.

     If a token set already exists, only its access token is updated. Otherwise,
     a new token set is created containing just the access token.

     - Parameter accessToken: The access token to store. If `nil`, the method ignores the request.
     */
    func setAccessToken(_ accessToken: String?)

    /**
     Retrieves and validates the stored access token.

     The access token is decoded and its expiration time is checked.
     If the token has expired or cannot be decoded, `nil` is returned.

     - Returns: A parsed `LoginIDJWTAccess` if the token is valid; otherwise `nil`.
     */
    func getParsedAccessToken() -> LoginIDJWTAccess?
}

/// Default Keychain-backed implementation of `SessionManaging`.
/// Handles secure storage and retrieval of authentication tokens,
/// scoped by a given `appId`.
final public class SessionManager: SessionManaging {
    private let appId: String

    /**
     Creates a new `SessionManager` scoped to a specific application ID.

     - Parameter appId: A unique application identifier used to namespace the stored token set.
     */
    public init(appId: String) {
        self.appId = appId
    }

    /// Returns the Keychain key used for storing the token set,
    /// namespaced by the `appId`.
    private func tokenSetKey() -> String {
        "com.loginid.session.set.\(appId)"
    }

    /**
     Stores the given `TokenSet` securely in the Keychain.

     - Parameter tokenSet: The token set to store. If `nil`, no action is taken.
     */
    public func setTokenSet(_ tokenSet: TokenSet?) {
        guard let tokenSet else {
            return
        }

        do {
            let data = try tokenSet.jsonData()
            _ = KeychainManager.setItem(key: tokenSetKey(), data: data)
        } catch {
            // Intentionally ignored.
        }
    }

    /**
     Returns the authorization token to use for authenticated requests.

     If `authzToken` is provided and non-empty, it is returned directly.
     Otherwise, the stored access token is returned if it exists and has not expired.

     - Parameter authzToken: An optional authorization token supplied by the caller.
     - Returns: A valid authorization token, or `nil` if none is available.
     */
    public func getAuthzToken(authzToken: String?) -> String? {
        if let authzToken, !authzToken.isEmpty {
            return authzToken
        }

        return getAccessToken()
    }

    /**
     Logs the user out by removing the stored token set from the Keychain.
     */
    public func logout() {
        _ = KeychainManager.removeItem(key: tokenSetKey())
    }

    /**
     Retrieves the stored token set from the Keychain.

     - Returns: The stored `TokenSet`, or `nil` if none exists or decoding fails.
     */
    private func getTokenSet() -> TokenSet? {
        guard let data = KeychainManager.getItem(key: tokenSetKey()) else {
            return nil
        }

        do {
            return try TokenSet.fromJSON(data)
        } catch {
            return nil
        }
    }
    
    /**
     Stores an access token in the current session.

     If a token set already exists, only its access token is updated. Otherwise,
     a new token set is created containing just the access token.

     - Parameter accessToken: The access token to store. If `nil`, no action is taken.
     */
    public func setAccessToken(_ accessToken: String?) {
        guard let accessToken else {
            return
        }

        let currentTokenSet = getTokenSet()

        let tokenSet = TokenSet(
            idToken: currentTokenSet?.idToken,
            accessToken: accessToken,
            refreshToken: currentTokenSet?.refreshToken,
            payloadSignature: currentTokenSet?.payloadSignature
        )

        setTokenSet(tokenSet)
    }

    /**
     Returns the stored access token if it exists and has not expired.

     - Returns: A valid access token, or `nil` if no valid token is available.
     */
    private func getAccessToken() -> String? {
        getParsedAccessToken()?.jwt
    }

    /**
     Retrieves and validates the stored access token.

     The access token is decoded and its expiration time is checked.
     If the token has expired or cannot be decoded, `nil` is returned.

     - Returns: A parsed `LoginIDJWTAccess` if the token is valid; otherwise `nil`.
     */
    public func getParsedAccessToken() -> LoginIDJWTAccess? {
        guard
            let jwt = getTokenSet()?.accessToken,
            let decodedJWT = LoginIDJWTAccess.decodeToLoginIdToken(jwt)
        else {
            return nil
        }

        let currentTime = Date().timeIntervalSince1970

        guard currentTime < Double(decodedJWT.exp) else {
            return nil
        }

        return decodedJWT
    }
}
