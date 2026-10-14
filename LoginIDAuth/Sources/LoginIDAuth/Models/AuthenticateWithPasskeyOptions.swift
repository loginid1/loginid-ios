//
//  AuthenticateWithPasskeyOptions.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-26.
//

import LoginIDCore

public struct AuthenticateWithPasskeyOptions {
    /// The type of username validation to be used.
    /// Defaults to `.other` and is omitted from the payload when `.other`.
    public let usernameType: UsernameType
    
    /// When true it will enable passkey keyboard autofill suggestions. Username does not need to be set.
    public let autofill: Bool?
    
    /// A unique identifier used to trace and correlate all events associated with a single authentication interaction.
    /// If you don’t provide this, the server may generate one automatically.
    public let traceId: String?
    
    /// An identifier for the device used in the authentication process.
    ///
    /// This value helps LoginID determine whether device-specific authentication
    /// flows are supported and allows future authentications to identify the
    /// device correctly. If not provided, the locally stored device ID is used.
    public let deviceId: String?
    
    /// Transaction-specific payload used to initiate a non-repudiation signature process.
    ///
    /// When provided, the payload is embedded in the passkey challenge and signed by the
    /// user with their passkey. This can be used to authorize sensitive actions, such as
    /// payments or changes to account information, and provides evidence that the
    /// transaction was approved by the passkey holder.
    public let txPayload: String?
    
    /// Optionally used with `txPayload`. A unique nonce that helps ensure the integrity
    /// of the transaction and prevents replay attacks.
    public let txNonce: String?

    /// Creates a new set of options for passkey authentication.
    ///
    /// - Parameters:
    ///   - usernameType: The type of username validation to use. Defaults to `.other`, which is omitted from the request payload.
    ///   - autoFill: When true, enables passkey keyboard autofill suggestions.
    ///   - traceId: An optional identifier used to trace and correlate all events associated with this authentication interaction.
    ///   - deviceId: An optional identifier for the device performing the authentication. Defaults to the locally stored device ID.
    ///   - txPayload: An optional transaction payload to be signed with the passkey for transaction confirmation.
    ///   - txNonce: An optional nonce used with `txPayload` to prevent replay attacks.
    public init(
        usernameType: UsernameType = .other,
        autoFill: Bool? = nil,
        traceId: String? = nil,
        deviceId: String? = nil,
        txPayload: String? = nil,
        txNonce: String? = nil
    ) {
        self.usernameType = usernameType
        self.autofill = autoFill
        self.traceId = traceId
        self.deviceId = deviceId
        self.txPayload = txPayload
        self.txNonce = txNonce
    }
    
    internal init(
        options: AuthenticateWithPasskeyOptions? = nil,
    ) {
        self.autofill = true
        self.usernameType = options?.usernameType ?? .other
        self.traceId = options?.traceId
        self.deviceId = options?.deviceId
        self.txPayload = options?.txPayload
        self.txNonce = options?.txNonce
    }
}
