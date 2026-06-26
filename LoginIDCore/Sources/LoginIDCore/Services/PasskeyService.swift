//
//  PasskeyService.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-25.
//

public struct PasskeyService: LoginIDPasskeyAPI {
    public init() {}
    
    public func regInit(
        request: RegInitRequestBody,
        userAgent: String?,
        authorization: String?
    ) async throws -> RegInit {
        try await RegAPI.regRegInit(
            regInitRequestBody: request,
            userAgent: userAgent,
            authorization: authorization
        )
    }
    
    public func regComplete(
        request: RegCompleteRequestBody
    ) async throws -> JWT {
        try await RegAPI.regRegComplete(regCompleteRequestBody: request)
    }
    
    public func authInit(
        request: AuthInitRequestBody,
        userAgent: String?
    ) async throws -> AuthInit {
        try await AuthAPI.authAuthInit(
            authInitRequestBody: request,
            userAgent: userAgent
        )
    }
    
    public func authComplete(
        request: AuthCompleteRequestBody
    ) async throws -> JWT {
        try await AuthAPI.authAuthComplete(authCompleteRequestBody: request)
    }
}
