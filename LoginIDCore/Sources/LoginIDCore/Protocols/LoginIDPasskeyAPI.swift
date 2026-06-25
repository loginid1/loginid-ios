//
//  LoginIDPasskeyAPI.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-25.
//

import LoginIDAPIClient

public protocol LoginIDPasskeyAPI: Sendable {
    func regInit(request: RegInitRequestBody, userAgent: String?) async throws -> RegInit
}
