//
//  LoginIDConfig.swift
//  Core
//
//  Created by Michael Braga on 2025-08-14.
//

import Foundation

/// A configuration object that stores and manages the LoginID service configurable options.
final public class LoginIDConfig: Sendable {
    /// The base URL of the LoginID service.
    ///
    /// This value is used to resolve the App ID and make API calls.
    private let baseUrl: String

    /// If true, uses TrustID, a Crypto–derived device identifier, as a device possession factor. Defaults to false.
    public let useTrustId: Bool

    /// Initializes the configuration with the specified base URL.
    ///
    /// - Parameter baseUrl: The base URL of the LoginID service.
    /// - Parameter useTrustId: If true, uses TrustID as a device possession factor. Defaults to false.
    public init(baseUrl: String, useTrustId: Bool = false) {
        self.baseUrl = baseUrl
        self.useTrustId = useTrustId
    }
    
    /// Extracts the App ID from the base URL using a regular expression or an empty string if not found.
    ///
    /// - Returns: A string representing the App ID if found otherwise an empty string .
    public func getAppIdOrEmpty() -> String {
        do {
            return try resolveAppId()
        } catch {
            return ""
        }
    }
    
    /// Extracts the App ID from the base URL using a regular expression.
    ///
    /// - Throws: A `LoginIDError` if the base URL does not contain a valid App ID.
    /// - Returns: A string representing the App ID.
    public func getAppId() throws -> String {
        return try resolveAppId()
    }

    /// Returns the configured base URL.
    ///
    /// - Returns: A string representing the base URL.
    public func getBaseUrl() -> String {
        return baseUrl
    }
    
    /// Extracts the App ID from the base URL using a regular expression.
    ///
    /// - Throws: A `LoginIDError` if the base URL does not contain a valid App ID.
    /// - Returns: A string representing the App ID.
    private func resolveAppId() throws -> String {
        let pattern = "https://([0-9A-Za-z-]+)\\.api.*\\.loginid\\.io"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let nsBaseUrl = baseUrl as NSString
        let results = regex.matches(
            in: baseUrl,
            options: [],
            range: NSRange(location: 0, length: nsBaseUrl.length)
        )

        if let match = results.first {
            let appIdRange = match.range(at: 1)
            let appId = nsBaseUrl.substring(with: appIdRange)
            return appId
        } else {
            throw LoginIDError(
                msgCode: "invalid_base_url",
                msg: "Invalid base URL. App ID not found."
            )
        }
    }
}
