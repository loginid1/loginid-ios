//
//  CreatePasskeyOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-24.
//

import LoginIDCore

public struct CreatePasskeyOptions {
    /// Authorization token used for accessing protected resources.
    public let authzToken: String?
    
    /// The type of username validation to be used.
    /// Defaults to `.other` and is omitted from the payload when `.other`.
    public let usernameType: UsernameType
    
    /// A human-palatable name for the user account, intended only for display on your passkeys and modals.
    public let displayName: String?
    
    /// A custom label or nickname when creating a passkey. Useful for distinguishing between multiple passkeys.
    public let passkeyName: String?
    
    /// An identifier for the device used when creating a passkey.
    ///
    /// This value helps LoginID determine whether device-specific authentication
    /// flows are supported and allows future authentications to identify the
    /// device correctly.
    ///
    /// - Note: Only used by `createPasskey`.
    public let deviceId: String?
    
    /// A unique identifier used to trace and correlate all events associated with a single registration interaction.
    /// If you don’t provide this, the server may generate one automatically.
    public let traceId: String?
    
    /// Creates a new set of options for passkey creation.
    ///
    /// - Parameters:
    ///   - authzToken: An optional authorization token used for accessing protected resources.
    ///   - usernameType: The type of username validation to use. Defaults to `.other`, which is omitted from the request payload.
    ///   - displayName: An optional human-readable name for the user account, displayed in passkeys and authentication prompts.
    ///   - passkeyName: An optional custom label or nickname for the passkey, useful for distinguishing between multiple passkeys.
    ///   - deviceId: An optional identifier for the device creating the passkey. Used to enable device-specific authentication flows and identify the device during future authentications.
    ///   - traceId: An optional identifier used to trace and correlate all events associated with this registration interaction.
    public init(
        authzToken: String? = nil,
        usernameType: UsernameType = .other,
        displayName: String? = nil,
        passkeyName: String? = nil,
        deviceId: String? = nil,
        traceId: String? = nil
    ) {
        self.authzToken = authzToken
        self.usernameType = usernameType
        self.displayName = displayName
        self.passkeyName = passkeyName
        self.deviceId = deviceId
        self.traceId = traceId
    }
    
    internal init(
        authzToken: String? = nil,
        options: CreatePasskeyOptions? = nil,
    ) {
        self.authzToken = authzToken
        self.usernameType = options?.usernameType ?? .other
        self.displayName = options?.displayName
        self.passkeyName = options?.passkeyName
        self.deviceId = options?.deviceId
        self.traceId = options?.traceId
    }
}
