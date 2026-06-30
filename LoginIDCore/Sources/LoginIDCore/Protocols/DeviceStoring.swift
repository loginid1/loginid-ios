//
//  DeviceStoring.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-24.
//

/// A protocol defining storage operations for persisting and retrieving
/// the device identifier.
public protocol DeviceStoring : Sendable {
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
