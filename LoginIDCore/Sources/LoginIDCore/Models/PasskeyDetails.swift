//
//  PasskeyDetails.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-26.
//

/// Represents a passkey credential stored and managed within the LoginID SDK.
///
/// Provides information about the passkey’s provider, creation date,
/// usage history, and associated device information.
public struct PasskeyDetails {
    /// AAGUID (Authenticator Attestation GUID) of the passkey provider.
    public let aaguid: String
    
    /// Indicates whether the credential is available across multiple devices (synced).
    public let id: String
    
    /// The original raw credential ID of the given passkey when it was created via WebAuthn.
    public let credentialId: String?
    
    /// Human-readable name assigned to the passkey.
    public let name: String
    
    /// Name of the passkey provider (e.g., Apple, Google).
    public let providerName: String?
    
    /// Timestamp when the passkey was created, in RFC3339 format.
    public let createdAt: String
    
    /// Timestamp when the passkey was last used, in RFC3339 format.
    public let lastUsedAt: String?
    
    /// Indicates whether the credential is available across multiple devices (synced).
    public let credentialSynced: Bool
    
    /// Information about the device from which the passkey was last used.
    public let lastUsedFromDevice: DeviceDetails?

    /// Initializes a new `PasskeyDetails` instance from a given `Passkey`.
    ///
    /// - Parameter result: A `Passkey` value, typically received from the backend API.
    public init(_ passkey: Passkey) {
        self.aaguid = passkey.aaguid
        self.id = passkey.id
        self.credentialId = passkey.credentialId
        self.name = passkey.name
        self.providerName = passkey.providerName
        self.createdAt = passkey.createdAt
        self.lastUsedAt = passkey.lastUsedAt
        self.credentialSynced = passkey.credentialSynced ?? false
        self.lastUsedFromDevice = passkey.lastUsedFromDevice.map(DeviceDetails.init)
    }
}
