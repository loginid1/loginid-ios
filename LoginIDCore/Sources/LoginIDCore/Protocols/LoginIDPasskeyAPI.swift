//
//  LoginIDPasskeyAPI.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-25.
//

public protocol LoginIDPasskeyAPI: Sendable {
    func regInit(request: RegInitRequestBody, userAgent: String?, authorization: String?) async throws -> RegInit
}
