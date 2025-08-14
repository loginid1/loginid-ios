//
//  DeviceUtils.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDAPIClient
import UIKit

/// Utility methods for retrieving device-related metadata
/// to be used in Multi-Factor Authentication (MFA) flows.
class DeviceUtils {
    /**
     Creates a `DeviceInfo` object populated with the current device's information.
     
     This method runs on the main actor because it accesses UIKit APIs (`UIDevice` and `UIScreen`)
     that are not thread-safe.
     
     - Parameter deviceId: An optional unique identifier for the device, if available.
     
     - Returns: A `DeviceInfo` instance containing:
       - `clientName`: Always `"iOS"`.
       - `clientType`: Set to `.other`.
       - `deviceId`: Passed from the parameter.
       - `osName`: `"iOS"`.
       - `osVersion`: The current iOS version string.
       - `screenHeight`: The device screen height in points (rounded to nearest integer).
       - `screenWidth`: The device screen width in points (rounded to nearest integer).
     
     - Note: The `osArch` field is not currently populated due to no direct API for iOS.
     */
    @MainActor
    static func getDeviceInfo(deviceId: String?) -> DeviceInfo {
        let osName = "iOS"
        let osVersion = UIDevice.current.systemVersion
        let screenSize = UIScreen.main.bounds.size

        return DeviceInfo(
            clientName: osName,
            clientType: DeviceInfo.ClientType.other,
            // no direct way for osArch for now
            // osArch: "",
            deviceId: deviceId,
            osName: osName,
            osVersion: osVersion,
            screenHeight: Int64(round(screenSize.height)),
            screenWidth: Int64(round(screenSize.width))
        )
    }
    
    /**
     Creates a `User-Agent` string suitable for inclusion in HTTP requests.
     
     This method gathers the device’s operating system name, version,
     and hardware model to form a simple, standardized `User-Agent` header.
     
     This format allows backend services to identify the client
     environment for logging, debugging, or compatibility checks.
     
     - Returns: A `String` containing the `User-Agent` value.
     */
    @MainActor
    static func getUserAgent() -> String {
        let osName = "iOS"
        let osVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model
        
        return "\(osName)/\(osVersion); \(deviceModel)"
    }
}
