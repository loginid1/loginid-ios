//
//  DeviceDetails.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-26.
//

import Foundation

/// Information about the device.
/// All of these attributes are optional and should be provided on a best-effort basis.
/// If provided, they may be taken into consideration in order to improve user experience.
public struct DeviceDetails {
    /// Client name (e.g. "Safari", "Chrome", "MyApp").
    public var clientName: String?

    /// Client type (e.g. "browser" or "other").
    public var clientType: String?

    /// Client version (e.g. "15.4", "100.0").
    public var clientVersion: String?

    /// A unique identifier for this device.
    public var deviceId: String?

    /// Indicates whether the client has access to Bluetooth.
    public var hasBluetooth: Bool

    /// Last usage timestamp in RFC3339 format.
    public var lastUsedAt: String?

    /// OS architecture (e.g. "x86_64", "arm64").
    public var osArch: String?

    /// OS name (e.g. "iOS", "macOS", "Windows").
    public var osName: String?

    /// OS version (e.g. "16.0", "13.5").
    public var osVersion: String?

    /// Screen height in pixels.
    public var screenHeight: Int64?

    /// Screen width in pixels.
    public var screenWidth: Int64?

    /// JSON string containing client WebAuthn capabilities.
    public var webauthnCapabilities: String?

    /// Initializes the device info from a Swift `DeviceInfo` model.
    ///
    /// - Parameter deviceInfo: The source model used to populate this instance.
    public init(_ deviceInfo: DeviceInfo) {
        self.clientName = deviceInfo.clientName
        self.clientType = deviceInfo.clientType?.rawValue
        self.clientVersion = deviceInfo.clientVersion
        self.deviceId = deviceInfo.deviceId
        self.hasBluetooth = deviceInfo.hasBluetooth ?? false
        self.lastUsedAt = deviceInfo.lastUsedAt
        self.osArch = deviceInfo.osArch
        self.osName = deviceInfo.osName
        self.osVersion = deviceInfo.osVersion
        self.screenHeight = deviceInfo.screenHeight
        self.screenWidth = deviceInfo.screenWidth
        self.webauthnCapabilities = deviceInfo.webauthnCapabilities
    }
}
