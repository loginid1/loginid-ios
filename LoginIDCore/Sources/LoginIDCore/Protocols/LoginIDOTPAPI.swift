//
//  LoginIDOTPAPI.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-28.
//

import Foundation

/// A protocol for handling One-Time Password (OTP) authentication flows.
public protocol LoginIDOTPAPI: Sendable {
    /// Requests an OTP code for an authenticated user.
    /// - Parameter authorization: The JWT authorization header.
    /// - Returns: An `AuthCode` object containing the OTP code and its expiration.
    /// - Throws: An error if the request fails.
    func authCodeRequest(authorization: String?) async throws -> AuthCode
    
    /// Verifies an OTP code and returns a JWT access token.
    /// - Parameter request: The verification request body.
    /// - Returns: A `JWT` object upon successful verification.
    /// - Throws: An error if verification fails.
    func authCodeVerify(request: AuthCodeVerifyRequestBody) async throws -> JWT
    
    /// Requests an OTP code to be sent via email.
    /// - Parameter request: The request body containing user information.
    /// - Throws: An error if the request fails.
    func authCodeRequestEmail(request: AuthCodeRequestSMSRequestBody) async throws
    
    /// Requests an OTP code to be sent via SMS.
    /// - Parameter request: The request body containing user information.
    /// - Throws: An error if the request fails.
    func authCodeRequestSMS(request: AuthCodeRequestSMSRequestBody) async throws
}
