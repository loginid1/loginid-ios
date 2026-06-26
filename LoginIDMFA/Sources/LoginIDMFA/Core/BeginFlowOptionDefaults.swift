//
//  BeginFlowOptionDefaults.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDCore

/// Provides defaulted accessors for `BeginFlowOptions`,
/// falling back to sensible values (such as the provided username)
/// when options are missing or incomplete.
final class BeginFlowOptionDefaults {
    /// `beginFlow` options sent in by the user.
    private let options: BeginFlowOptions?
    
    /// User's username.
    private let username: String
    
    /// Trust ID manager for signing.
    private let trustIdStore: TrustIDManaging

    /// LoginID SDK configuration.
    private let config: LoginIDConfig

    /// Device ID store.
    private let store: DeviceStoring

    /**
     Creates a new defaults helper for MFA flow options.
     
     - Parameters:
       - username: The username to fall back to if `displayName` is not provided.
       - options: Optional `BeginFlowOptions` from which to read values.
       - trustId: A `TrustIDManaging` implementation for managing device trust identifiers.
       - config: The `LoginIDConfig` containing API configuration values.
       - store: An `DeviceStoring` implementation for persisting device ID.
     */
    public init(
        username: String,
        options: BeginFlowOptions?,
        trustId: TrustIDManaging,
        config: LoginIDConfig,
        store: DeviceStoring
    ) {
        self.username = username
        self.options = options
        self.trustIdStore = trustId
        self.config = config
        self.store = store
    }
    
    /// The device identifier to use, falling back to the stored value if not provided.
    var deviceId: String? {
        return options?.deviceId ?? store.getDeviceId()
    }
    
    /// The display name to use, falling back to `username` if not provided or empty.
    var displayName: String {
        return options?.displayName?.isEmpty == false ? options!.displayName! : username
    }
    
    /// The type of username validation to use, defaulting to `.other`.
    var usernameType: UsernameType {
        return options?.usernameType ?? .other
    }
    
    /// The transaction payload to use, if provided.
    var txPayload: String? {
        return options?.txPayload
    }
    
    /// A dictionary of trust items for the MFA flow.
    var trustItems: [String: String] {
        get throws {
            let walletId: String
            if txPayload != nil {
                walletId = try trustIdStore.signWithTrustId()
            } else {
                walletId = ""
            }

            let merchantId = options?.merchantTrustId ?? ""

            let authId: String
            if config.useTrustId, walletId.isEmpty, merchantId.isEmpty, !username.isEmpty {
                authId = try trustIdStore.signWithTrustId(username: username)
            } else {
                authId = ""
            }

            return [
                "auth": authId,
                "wallet": walletId,
                "merchant": merchantId,
            ]
        }
    }
    
    /// The trace identifier for correlating MFA events, if provided.
    var traceId: String? {
        return options?.traceId
    }
    
    /// A `User` object constructed from the resolved defaults.
    var user: MfaUser {
        return MfaUser(
            displayName: displayName,
            username: username,
            usernameType: usernameType.rawValue,
        )
    }
}
