//
//  LoginIDConfig.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-07-31.
//

import Foundation

/// A configuration object that stores and manages the LoginID service configurable options.
public class LoginIDConfig: NSObject {
    /// The base URL of the LoginID service.
    ///
    /// This value is used to resolve the App ID and make API calls.
    private let baseUrl: String

    /// Initializes the configuration with the specified base URL.
    ///
    /// - Parameter baseUrl: The base URL of the LoginID service.
    public init(baseUrl: String) {
        self.baseUrl = baseUrl

        super.init()
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
        let pattern = "https://([0-9a-fA-F-]+)\\.api.*\\.loginid\\.io"
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
