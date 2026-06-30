//
//  OTPService.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-28.
//

import Foundation

/// A service that implements the `LoginIDOTPAPI` protocol using the generated `AuthAPI`.
public struct OTPService: LoginIDOTPAPI {
    /// Initializes a new instance of `OTPService`.
    public init() {}
    
    public func authCodeRequest(authorization: String?) async throws -> AuthCode {
        try await AuthAPI.authAuthCodeRequest(authorization: authorization)
    }
    
    public func authCodeVerify(request: AuthCodeVerifyRequestBody) async throws -> JWT {
        try await AuthAPI.authAuthCodeVerify(authCodeVerifyRequestBody: request)
    }
    
    public func authCodeRequestEmail(request: AuthCodeRequestSMSRequestBody) async throws {
        try await AuthAPI.authAuthCodeRequestEmail(authCodeRequestSMSRequestBody: request)
    }
    
    public func authCodeRequestSMS(request: AuthCodeRequestSMSRequestBody) async throws {
        try await AuthAPI.authAuthCodeRequestSMS(authCodeRequestSMSRequestBody: request)
    }
}
