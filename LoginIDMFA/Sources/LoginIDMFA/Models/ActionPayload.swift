//
//  ActionPayload.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

/// The final result after validating the MFA session info
internal struct ActionPayload {
    /// The MFA state session.
    ///
    /// This should be obtained from a previous MFA request or initiation step.
    public let session: String
    
    /// The payload required for completing the authentication factor.
    ///
    /// This typically contains user input or challenge-response data.
    public let payload: String
}
