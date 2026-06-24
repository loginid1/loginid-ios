//
//  MFAStore.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDCore

/// A protocol defining storage operations for persisting and retrieving
/// the device identifier used in Multi-Factor Authentication (MFA) flows.
public protocol MFAStoring : Sendable {
    /**
     Persists a device identifier.
     
     - Parameter deviceId: The unique identifier for the device. If `nil`, the store should ignore the request.
     */
    func storeDeviceId(_ deviceId: String?)
    /**
     Retrieves the stored device identifier, if available.
     
     - Returns: The stored device identifier as a `String`, or `nil` if none is found.
     */
    func getDeviceId() -> String?
    
    /**
     Persists the current MFA session information.

     - Parameter info: The `MFAInfo` to store. If `nil`, the call is ignored.
     - Note: The info is encoded to JSON (`UTF-8`) and stored securely in the Keychain.
     */
    func storeMFAInfo(_ info: MFAInfo?)
    
    /**
     Retrieves the stored MFA session information, if available.

     - Returns: A decoded `MFAInfo` instance, or `nil` if not found or if decoding fails.
     */
    func getMFAInfo() -> MFAInfo?

    /**
     Removes any persisted MFA session information.

     Use this when the MFA flow is completed or intentionally reset.
     */
    func clearMFAInfo()
    
    /**
     Persists the current Trust set information.

     - Parameter trustSet: The `TrustSet` to store. If `nil`, the call is ignored.
     - Note: The info is encoded to JSON (`UTF-8`) and stored securely in the Keychain.
     */
    func storeTrustSet(_ trustSet: TrustSet?)
    
    /**
     Retrieves the stored trust set information, if available.

     - Returns: A decoded `TrustSet` instance, or `nil` if not found or if decoding fails.
     */
    func getTrustSet() -> TrustSet?

    /**
     Removes any persisted trust set information.

     Use this when the MFA flow is completed or intentionally reset.
     */
    func clearTrustSet()
    
    /**
     Updates the session property of the stored MFA information.

     - Parameter session: The new session string to store. If `nil`, the session is not updated.
     */
    func updateMFASession(_ session: String?)
}

/// Default Keychain-backed implementation of `MFAStoring`.
/// Stores the device ID securely, scoped by a given `appId`.
final class MFAStore: MFAStoring {
    private let appId: String

    /**
     Creates a new `MFAStore` instance scoped to a specific application ID.
     
     - Parameter appId: A unique application identifier used to namespace the stored device ID.
     */
    public init(appId: String) {
        self.appId = appId
    }
    
    /// Returns the full Keychain key name for storing the device ID, namespaced by `appId`.
    private func deviceIdKey() -> String {
        return "com.loginid.deviceId.\(appId)"
    }
    
    /// Returns the full Keychain key name for storing MFA info, namespaced by `appId`.
    private func mfaInfoKey() -> String {
        return "com.loginid.mfa.info.\(appId)"
    }
    
    /// Returns the full Keychain key name for storing MFA trust set, namespaced by `appId`.
    private func trustSetKey() -> String {
        return "com.loginid.mfa.trustset.\(appId)"
    }
    
    /**
     Stores the device identifier securely in the Keychain.
     
     - Parameter deviceId: The device identifier to store. If `nil`, the method does nothing.
     
     This method converts the `String` into UTF-8 encoded `Data` before storing it.
     */
    func storeDeviceId(_ deviceId: String?) {
        guard let deviceId = deviceId else {
            return
        }

        let key = deviceIdKey()
        if let deviceData = deviceId.data(using: .utf8) {
            _ = KeychainManager.setItem(key: key, data: deviceData)
        }
    }

    /**
     Retrieves the device identifier from the Keychain.
     
     - Returns: The stored device identifier as a `String`, or `nil` if not found
       or if the data cannot be decoded as UTF-8 text.
     */
    func getDeviceId() -> String? {
        let key = deviceIdKey()

        if let deviceData = KeychainManager.getItem(key: key),
           let deviceId = String(data: deviceData, encoding: .utf8) {
            return deviceId
        }
        
        return nil
    }
    
    /**
     Stores the `MFAInfo` securely in the Keychain.

     - Parameter info: The `MFAInfo` to store. If `nil`, the method does nothing.

     The value is encoded using `JSONCoding.encoder()` from your `MFAInfo` type and saved as Data.
     */
    func storeMFAInfo(_ info: MFAInfo?) {
        guard let info = info else {
            return
        }

        do {
            let data = try info.jsonData()
            _ = KeychainManager.setItem(key: mfaInfoKey(), data: data)
        } catch {
        }
    }

    /**
     Retrieves the stored `MFAInfo` from the Keychain.

     - Returns: A decoded `MFAInfo` if available and valid; otherwise `nil`.
     - Behavior on corruption: If stored data cannot be decoded, it is cleared to avoid repeated failures.
     */
    func getMFAInfo() -> MFAInfo? {
        let key = mfaInfoKey()
        guard let data = KeychainManager.getItem(key: key) else {
            return nil
        }

        do {
            return try MFAInfo.fromJSON(data)
        } catch {
            // Data is corrupt or incompatible; clear and return nil.
            _ = KeychainManager.removeItem(key: mfaInfoKey())
            return nil
        }
    }

    /**
     Clears any stored `MFAInfo` from the Keychain.
     */
    func clearMFAInfo() {
        _ = KeychainManager.removeItem(key: mfaInfoKey())
    }
    
    /**
     Stores the `TrustSet` securely in the Keychain.

     - Parameter trustSet: The `TrustSet` to store. If `nil`, the method does nothing.

     The value is encoded using `JSONCoding.encoder()` from your `TrustSet` type and saved as Data.
     */
    func storeTrustSet(_ trustSet: TrustSet?) {
        guard let trustSet = trustSet else {
            return
        }

        do {
            let data = try trustSet.jsonData()
            _ = KeychainManager.setItem(key: trustSetKey(), data: data)
        } catch {
        }
    }

    /**
     Retrieves the stored `TrustSet` from the Keychain.

     - Returns: A decoded `TrustSet` if available and valid; otherwise `nil`.
     - Behavior on corruption: If stored data cannot be decoded, it is cleared to avoid repeated failures.
     */
    func getTrustSet() -> TrustSet? {
        let key = trustSetKey()
        guard let data = KeychainManager.getItem(key: key) else {
            return nil
        }

        do {
            return try TrustSet.fromJSON(data)
        } catch {
            // Data is corrupt or incompatible; clear and return nil.
            _ = KeychainManager.removeItem(key: trustSetKey())
            return nil
        }
    }

    /**
     Clears any stored `TrustSet` from the Keychain.
     */
    func clearTrustSet() {
        _ = KeychainManager.removeItem(key: trustSetKey())
    }
    
    /**
     Updates the session property of the stored MFA information.

     - Parameter session: The new session string to store. If `nil`, the session is not updated.
     */
    func updateMFASession(_ session: String?) {
        guard let newSession = session, let oldInfo = getMFAInfo() else {
            return
        }
        
        let newInfo = MFAInfo(
            info: oldInfo,
            session: newSession
        )
        storeMFAInfo(newInfo)
    }
}
