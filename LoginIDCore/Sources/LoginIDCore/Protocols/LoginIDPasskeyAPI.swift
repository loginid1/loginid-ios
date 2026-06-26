//
//  LoginIDPasskeyAPI.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-25.
//

public protocol LoginIDPasskeyAPI: Sendable {
    func regInit(request: RegInitRequestBody, userAgent: String?, authorization: String?) async throws -> RegInit
    func regComplete(request: RegCompleteRequestBody) async throws -> JWT
    func authInit(request: AuthInitRequestBody, userAgent: String?) async throws -> AuthInit
    func authComplete(request: AuthCompleteRequestBody) async throws -> JWT
}
