//
//  DeviceStore.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-24.
//

final public class DeviceStore: DeviceStoring {
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

    /**
     Stores the device identifier securely in the Keychain.

     - Parameter deviceId: The device identifier to store. If `nil`, the method does nothing.

     This method converts the `String` into UTF-8 encoded `Data` before storing it.
     */
    public func storeDeviceId(_ deviceId: String?) {
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
    public func getDeviceId() -> String? {
        let key = deviceIdKey()

        if let deviceData = KeychainManager.getItem(key: key),
           let deviceId = String(data: deviceData, encoding: .utf8) {
            return deviceId
        }

        return nil
    }
}
