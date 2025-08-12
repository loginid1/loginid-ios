//
//  MFAInfo.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import LoginIDAPIClient
import Foundation

/// Represents multi-factor authentication (MFA) information for a user.
public struct MFAInfo : Codable {
    /// The username of the account undergoing MFA.
    /// Optional — may be omitted if the username is not yet known or required.
    let username: String?
    
    /// The current MFA flow being executed.
    /// Optional — may be `nil` if the flow has not started.
    let flow: MfaNext.Flow?
    
    /// The list of next possible MFA actions to perform.
    /// Optional — may be `nil` or empty if there are no available actions.
    let next: [MfaAction]?
    
    /// An opaque object containing session data.
    /// Optional — may be `nil` if there is no active session.
    let session: String?
    
    /// Creates an `MFAInfo` instance from JSON data.
    /// - Parameter data: The JSON data to decode.
    /// - Throws: An error if decoding fails.
    /// - Returns: A decoded `MFAInfo` instance.
    static func fromJSON(_ data: Data) throws -> MFAInfo {
        let decoder = JSONCoding.decoder()
        return try decoder.decode(MFAInfo.self, from: data)
    }
    
    public init(result: MfaNext, username: String?) {
        self.username = username
        self.flow = result.flow
        self.next = result.next
        self.session = result.session
    }
    
    public init(username: String?, flow: MfaNext.Flow?) {
        self.username = username
        self.flow = flow
        self.next = []
        self.session = nil
    }
    
    /// Encodes the `MFAInfo` instance into JSON data.
    /// - Throws: An error if encoding fails.
    /// - Returns: Encoded JSON data.
    func jsonData() throws -> Data {
        let encoder = JSONCoding.encoder()
        return try encoder.encode(self)
    }
}
