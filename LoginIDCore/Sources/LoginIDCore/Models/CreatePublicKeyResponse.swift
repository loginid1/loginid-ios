//
//  CreatePublicKeyResponse.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

/// Represents the response from creating a passkey public key credential.
///
/// All properties are Base64URL-encoded strings derived from the raw binary data.
public struct CreatePublicKeyResponse: Sendable {
    /// The credential identifier.
    public let id: String
    
    /// The raw credential identifier.
    public let rawId: String
    
    /// The client data JSON used in the credential creation ceremony.
    public let clientDataJSON: String
    
    /// The attestation object generated during credential creation.
    public let attestationObject: String
    
    /// The authenticator attachment modality reported for this registration.
    ///
    /// `nil` when the platform does not report it (before iOS 16.6).
    public let authenticatorAttachment: CreationResult.AuthenticatorAttachment?

    /**
     Creates a new `CreatePublicKeyResponse` by Base64URL-encoding the provided raw data.
     
     - Parameters:
       - id: The credential identifier.
       - rawId: The raw credential identifier.
       - clientDataJSON: The client data JSON.
       - attestationObject: The attestation object.
       - authenticatorAttachment: The authenticator attachment modality, if known.
     */
    init(
        id: Data,
        rawId: Data,
        clientDataJSON: Data,
        attestationObject: Data,
        authenticatorAttachment: CreationResult.AuthenticatorAttachment? = nil
    ) {
        self.id = id.base64URLEncodedString()
        self.rawId = rawId.base64URLEncodedString()
        self.clientDataJSON = clientDataJSON.base64URLEncodedString()
        self.attestationObject = attestationObject.base64URLEncodedString()
        self.authenticatorAttachment = authenticatorAttachment
    }
}
