//
//  PasskeyService.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-25.
//

import LoginIDAPIClient

public struct PasskeyService: LoginIDPasskeyAPI {
    public init() {}
    
    public func regInit(
        request: RegInitRequestBody,
        userAgent: String?
    ) async throws -> RegInit {
        try await RegAPI.regRegInit(
            regInitRequestBody: request,
            userAgent: userAgent
        )
    }
}
