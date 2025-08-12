//
//  MFAStore.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

/// A protocol defining storage operations for persisting and retrieving
/// the device identifier used in Multi-Factor Authentication (MFA) flows.
public protocol MFAStoring {
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
        return "LOGINID_DEVICE_ID_\(appId)"
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
}
