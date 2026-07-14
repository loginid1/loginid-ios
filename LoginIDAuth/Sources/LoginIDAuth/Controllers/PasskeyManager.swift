//
//  PasskeyManager.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-26.
//

import LoginIDCore

/// Provides an interface for managing a user's passkeys.
internal final class PasskeyManager : Sendable {
    private let session: SessionManaging
    private let passkeyApi: LoginIDPasskeyManagementAPI
    
    /// Initializes a new instance of the passkey manager.
    /// - Parameters:
    ///   - sessionStore: The session manager for handling authentication tokens.
    ///   - passkeyApi: The API service for passkey management operations.
    init(
        sessionStore: SessionManaging,
        passkeyApi: LoginIDPasskeyManagementAPI
    ) {
        self.session = sessionStore
        self.passkeyApi = passkeyApi
    }

    /// Lists all passkeys associated with the authenticated user.
    /// - Parameter options: Options for the request, including an optional authorization token.
    /// - Returns: An array of `LoginIDPasskey` objects.
    /// - Throws: A `LoginIDError` if the request fails.
    public func listPasskeys(
        options: ListPasskeysOptions?
    ) async throws -> [PasskeyDetails] {
        let authzToken = session.getAuthzToken(authzToken: options?.authzToken)
        let result = try await passkeyApi.listPasskeys(authorization: authzToken)
        return PasskeyDetails.fromArray(result)
    }

    /// Renames a specific passkey.
    /// - Parameters:
    ///   - id: The unique identifier of the passkey to rename.
    ///   - name: The new name for the passkey.
    ///   - options: Options for the request, including an optional authorization token.
    /// - Throws: A `LoginIDError` if the request fails.
    public func renamePasskey(
        id: String,
        name: String,
        options: RenamePasskeyOptions?
    ) async throws {
        let authzToken = session.getAuthzToken(authzToken: options?.authzToken)
        try await passkeyApi.renamePasskey(id: id, name: name, authorization: authzToken)
    }

    /// Deletes a specific passkey.
    /// - Parameters:
    ///   - id: The unique identifier of the passkey to delete.
    ///   - options: Options for the request, including an optional authorization token.
    /// - Throws: A `LoginIDError` if the request fails.
    public func deletePasskey(
        id: String,
        options: DeletePasskeyOptions?
    ) async throws {
        let authzToken = session.getAuthzToken(authzToken: options?.authzToken)
        try await passkeyApi.deletePasskey(id: id, authorization: authzToken)
    }
}
