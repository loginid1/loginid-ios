//
//  LoginIDPasskeyManagementAPI.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-26.
//

import Foundation

/// A protocol for managing a user's passkeys.
public protocol LoginIDPasskeyManagementAPI: Sendable {
    /// Fetches the list of passkeys for the authenticated user.
    /// - Parameter authorization: The authorization token for the request.
    /// - Returns: An array of `Passkey` objects.
    /// - Throws: An error if the request fails.
    func listPasskeys(authorization: String?) async throws -> [Passkey]
    
    /// Renames a specific passkey.
    /// - Parameters:
    ///   - id: The ID of the passkey to rename.
    ///   - name: The new name for the passkey.
    ///   - authorization: The authorization token for the request.
    /// - Throws: An error if the request fails.
    func renamePasskey(id: String, name: String, authorization: String?) async throws
    
    /// Deletes a specific passkey.
    /// - Parameters:
    ///   - id: The ID of the passkey to delete.
    ///   - authorization: The authorization token for the request.
    /// - Throws: An error if the request fails.
    func deletePasskey(id: String, authorization: String?) async throws
}
