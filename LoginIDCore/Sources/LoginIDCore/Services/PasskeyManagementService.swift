//
//  PasskeyManagementService.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-26.
//

import Foundation

/// A service that implements the `LoginIDPasskeyManagementAPI` protocol using the generated `PasskeysAPI`.
public struct PasskeyManagementService: LoginIDPasskeyManagementAPI {
    /// Initializes a new instance of `PasskeyManagementService`.
    public init() {}
    
    public func listPasskeys(authorization: String?) async throws -> [Passkey] {
        return try await PasskeysAPI.passkeysPasskeysList(authorization: authorization)
    }
    
    public func renamePasskey(id: String, name: String, authorization: String?) async throws {
        let requestBody = PasskeyRenameRequestBody(name: name)
        try await PasskeysAPI.passkeysPasskeyRename(
            id: id,
            passkeyRenameRequestBody: requestBody,
            authorization: authorization
        )
    }
    
    public func deletePasskey(id: String, authorization: String?) async throws {
        try await PasskeysAPI.passkeysPasskeyDelete(
            id: id,
            authorization: authorization
        )
    }
}
