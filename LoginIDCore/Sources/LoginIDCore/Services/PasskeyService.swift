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
}
