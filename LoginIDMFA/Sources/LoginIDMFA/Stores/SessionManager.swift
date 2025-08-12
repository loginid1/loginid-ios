//
//  SessionManager.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

/// A protocol defining methods for managing an MFA session's lifecycle.
protocol SessionManaging {
    /**
     Logs the user out of the current session and removes any stored credentials or tokens.
     */
    func logout()
    
    /**
     Persists a session's token set securely.
     
     - Parameter tokenSet: The `TokenSet` to store. If `nil`, the method should ignore the request.
     */
    func setTokenSet(_ tokenSet: TokenSet?)
}

/// Default Keychain-backed implementation of `SessionManaging`.
/// Handles secure storage and removal of MFA session tokens, scoped by a given `appId`.
final class SessionManager : SessionManaging {
    private let appId: String

    /**
     Creates a new `SessionManager` scoped to a specific application ID.
     
     - Parameter appId: A unique application identifier used to namespace the stored session token.
     */
    public init(appId: String) {
        self.appId = appId
    }

    /// Returns the Keychain key used for storing the MFA session token set,
    /// namespaced by the `appId`.
    private func tokenSetKey() -> String {
        return "LOGINID_MFA_SESSION_SET_\(appId)"
    }
    
    /**
     Stores the given `TokenSet` securely in the Keychain.
     
     - Parameter tokenSet: The token set to store. If `nil`, no action is taken.
     */
    func setTokenSet(_ tokenSet: TokenSet?) {
        guard let tokenSet = tokenSet else {
            return
        }

        do {
            let data = try tokenSet.jsonData()
            _ = KeychainManager.setItem(key: tokenSetKey(), data: data)
        } catch {
        }
    }
    
    /**
     Logs the user out by removing the stored MFA session token set from the Keychain.
     */
    func logout() {
        _ = KeychainManager.removeItem(key: tokenSetKey())
    }
}
