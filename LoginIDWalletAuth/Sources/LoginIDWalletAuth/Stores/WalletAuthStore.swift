//
//  WalletAuthStore.swift
//  LoginIDWalletAuth
//
//  Created by Michael Braga on 2025-08-14.
//

import LoginIDCore

/// A protocol defining storage operations for persisting and retrieving
/// a trace identifier used to correlate wallet authentication flows end-to-end.
public protocol WalletAuthStoring : Sendable {
    /**
     Persists a trace identifier.

     Use this to store a value that links related requests/responses across
     an authentication session for observability.

     - Parameter traceId: The trace identifier to store. If `nil`, the call is ignored.
     */
    func storeTraceId(_ traceId: String?)
    
    /**
     Retrieves the stored trace identifier, if available.

     - Returns: The stored trace identifier as a `String`, or `nil` if none is found.
     */
    func getTraceId() -> String?
    
    /**
     Persists a checkout identifier.

     Use this to store the identifier generated on the merchant side.

     - Parameter checkoutId: The checkout identifier to store. If `nil`, the call is ignored.
     */
    func storeCheckoutId(_ checkoutId: String?)

    /**
     Retrieves the stored checkout identifier, if available.

     - Returns: The stored checkout identifier as a `String`, or `nil` if none is found.
     */
    func getCheckoutId() -> String?
}

/**
 A Keychain-backed store for wallet authentication metadata.

 `WalletAuthStore` namespaces all persisted values by the provided `appId`
 to avoid collisions when multiple applications or environments share the same device.
 */
final class WalletAuthStore: WalletAuthStoring {
    private let appId: String

    /**
     Creates a new `WalletAuthStore` instance scoped to a specific application ID.
     
     - Parameter appId: A unique application identifier used to namespace the stored values.
     */
    public init(appId: String) {
        self.appId = appId
    }
    
    /// Returns the full Keychain key name for storing the trace ID, namespaced by `appId`.
    private func traceIdKey() -> String {
        return "LOGINID_TRACE_ID_\(appId)"
        return "com.loginid.traceid.\(appId)"
    }
    
    /// Returns the full Keychain key name for storing the checkout ID, namespaced by `appId`.
    private func checkoutIdKey() -> String {
        return "com.loginid.merchanttrustid.\(appId)"
    }
    
    /**
     Stores the trace identifier securely in the Keychain.

     - Parameter traceId: The trace identifier to persist. If `nil`, the method does nothing.

     The value is converted to UTF-8 encoded `Data` and saved using `KeychainManager`.
     */
    func storeTraceId(_ traceId: String?) {
        guard let traceId = traceId else {
            return
        }

        let key = traceIdKey()
        if let traceIdData = traceId.data(using: .utf8) {
            _ = KeychainManager.setItem(key: key, data: traceIdData)
        }
    }
    
    /**
     Retrieves the trace identifier from the Keychain.

     - Returns: The stored trace identifier as a `String`, or `nil` if not found
       or if the stored bytes cannot be decoded as UTF-8 text.
     */
    func getTraceId() -> String? {
        let key = traceIdKey()

        if let traceIdData = KeychainManager.getItem(key: key),
           let traceId = String(data: traceIdData, encoding: .utf8) {
            return traceId
        }
        
        return nil
    }
    
    /**
     Stores the checkout identifier securely in the Keychain.

     - Parameter checkoutId: The checkout identifier to persist. If `nil`, the method does nothing.

     The value is converted to UTF-8 encoded `Data` and saved using `KeychainManager`.
     */
    func storeCheckoutId(_ checkoutId: String?) {
        guard let checkoutId = checkoutId else {
            return
        }

        let key = checkoutIdKey()
        if let checkoutIdData = checkoutId.data(using: .utf8) {
            _ = KeychainManager.setItem(key: key, data: checkoutIdData)
        }
    }

    /**
     Retrieves the checkout identifier from the Keychain.

     - Returns: The stored checkout identifier as a `String`, or `nil` if not found
       or if the stored bytes cannot be decoded as UTF-8 text.
     */
    func getCheckoutId() -> String? {
        let key = checkoutIdKey()

        if let checkoutIdData = KeychainManager.getItem(key: key),
           let checkoutId = String(data: checkoutIdData, encoding: .utf8) {
            return checkoutId
        }
        
        return nil
    }
}
