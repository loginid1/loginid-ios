//
//  PasskeyCreationResult.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-06-23.
//

import LoginIDCore

/// Represents the result of a passkey credential creation.
public struct PasskeyCreationResult: Sendable, Codable, Hashable {
    /// Base64URL-encoded attestation object bytes.
    public let attestationObject: String
    
    /// The authenticator attachment modality: `"platform"` or `"cross-platform"`.
    public let authenticatorAttachment: String?
    
    /// Base64URL-encoded authenticator data bytes.
    public let authenticatorData: String?
    
    /// Base64URL-encoded UTF-8 JSON bytes representing the client data.
    public let clientDataJSON: String
    
    /// Base64URL-encoded credential ID bytes.
    public let credentialId: String
    
    /// Base64URL-encoded DER SubjectPublicKeyInfo bytes.
    public let publicKey: String?
    
    /// This operation returns the COSEAlgorithmIdentifier of the new credential.
    public let publicKeyAlgorithm: Int64?
    
    /// These values are the transports that the authenticator is believed to support.
    public let transports: [String]?

    /**
     Initializes a `PasskeyCreationResult` from an auto-generated `CreationResult`.
     - Parameter result: The auto-generated result object.
     */
    internal init(from result: CreationResult) {
        self.attestationObject = result.attestationObject
        self.authenticatorAttachment = result.authenticatorAttachment?.rawValue
        self.authenticatorData = result.authenticatorData
        self.clientDataJSON = result.clientDataJSON
        self.credentialId = result.credentialId
        self.publicKey = result.publicKey
        self.publicKeyAlgorithm = result.publicKeyAlgorithm
        self.transports = result.transports?.map { $0.rawValue }
    }
}
