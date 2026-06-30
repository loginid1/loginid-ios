//
//  OTP.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import LoginIDCore

/// Provides an interface for handling One-Time Password (OTP) flows.
final class OTP: Sendable {
    private let session: SessionManaging
    private let otpApi: LoginIDOTPAPI
    
    /// Initializes a new instance of the OTP controller.
    /// - Parameters:
    ///   - sessionStore: The session manager for handling authentication tokens.
    ///   - otpApi: The API service for OTP operations.
    init(
        sessionStore: SessionManaging,
        otpApi: LoginIDOTPAPI
    ) {
        self.session = sessionStore
        self.otpApi = otpApi
    }
    
    /// Requests an OTP code for an already authenticated user.
    /// - Parameter options: Options for the request, including an optional authorization token.
    /// - Returns: An `OTPResult` containing the generated code and its expiration.
    /// - Throws: A `LoginIDError` if the request fails.
    public func requestOtp(
        options: RequestOtpOptions?
    ) async throws -> OTPResult {
        let authzToken = session.getAuthzToken(authzToken: options?.authzToken)
        let result = try await otpApi.authCodeRequest(authorization: authzToken)
        return OTPResult(result: result)
    }
    
    /// Validates an OTP code for a given user.
    /// - Parameters:
    ///   - username: The user's username.
    ///   - otp: The OTP code to validate.
    ///   - options: Options for the request, including the username type.
    /// - Returns: An `AuthResult` containing authentication tokens upon success.
    /// - Throws: A `LoginIDError` if validation fails.
    public func validateOtp(
        username: String,
        otp: String,
        options: ValidateOtpOptions?
    ) async throws -> AuthResult {
        let user = Defaults.userLogin(username: username, usernameType: options?.usernameType)
        let requestBody = AuthCodeVerifyRequestBody(authCode: otp, user: user)
        let result = try await otpApi.authCodeVerify(request: requestBody)

        session.setAccessToken(result.jwtAccess)

        return AuthResult(result: result)
    }

    /// Requests an OTP and sends it to the user via a specified method (email or SMS).
    /// - Parameters:
    ///   - username: The user's username.
    ///   - method: The delivery method for the OTP (`.email` or `.`sms`).
    ///   - options: Options for the request, including the username type.
    /// - Throws: A `LoginIDError` if the request fails or an invalid method is provided.
    public func requestAndSendOtp(
        username: String,
        method: MessageMethod,
        options: RequestAndSendOtpOptions?
    ) async throws {
        let user = Defaults.userLogin(username: username, usernameType: options?.usernameType)
        let requestBody = AuthCodeRequestSMSRequestBody(user: user)

        switch method {
        case .email:
            try await otpApi.authCodeRequestEmail(request: requestBody)
        case .sms:
            try await otpApi.authCodeRequestSMS(request: requestBody)
        }
    }
}
