//
//  Utils.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import LoginIDCore

/// Provides utility functions for configuration and session management.
final class Utils: Sendable {
    private let config: LoginIDConfig
    private let passkeyApi: LoginIDPasskeyAPI
    private let session: SessionManaging

    /// Initializes a new instance of the Utils controller.
    /// - Parameters:
    ///   - config: The LoginID configuration.
    ///   - sessionManager: The session manager for handling authentication tokens.
    public init(
        config: LoginIDConfig,
        passkeyApi: LoginIDPasskeyAPI,
        sessionManager: SessionManaging
    ) {
        self.config = config
        self.passkeyApi = passkeyApi
        self.session = sessionManager
    }

    /// Verifies the current SDK configuration by making a test API call.
    /// - Returns: A `LoginIDConfigResult` if there is a configuration issue, otherwise `nil`.
    public func verifyConfigSettings() async -> LoginIDConfigResult? {
        if config.getBaseUrl().isEmpty {
            return LoginIDConfigResult(
                solution: "Set the base URL with configure()",
                code: "not_found_base_url",
                errorMessage: "Base URL is not set"
            )
        }

        let appId = config.getAppIdOrEmpty()

        if appId.isEmpty {
            return LoginIDConfigResult(
                solution: "Please verify that your base URL is correct.",
                code: "invalid_app_id",
                errorMessage: "Invalid app ID"
            )
        }

        let user = Defaults.userLogin(username: "", usernameType: nil)
        let deviceInfo = await DeviceUtils.getDeviceInfo(deviceId: nil)

        let authInitRequestBody = AuthInitRequestBody(
            app: Application(id: appId),
            deviceInfo: deviceInfo,
            user: user
        )

        do {
            _ = try await passkeyApi.authInit(request: authInitRequestBody, userAgent: nil)
        } catch let error as ErrorResponse {
            let err = LoginIDError.fromErrorResponse(from: error)
            return LoginIDConfigResult(
                solution: "Verify that your application exists and the base URL is correct.",
                code: err.msgCode,
                errorMessage: err.msg
            )
        } catch {
            return LoginIDConfigResult(
                solution: "Verify that your application exists and the base URL is correct.",
                code: "unknown",
                errorMessage: "Unknown error"
            )
        }

        return nil
    }

    /// Retrieves information about the current authenticated session.
    /// - Returns: A `SessionInfo` object if a valid session exists, otherwise `nil`.
    public func getSessionInfo() -> SessionInfo? {
        guard let parsedToken = session.getParsedAccessToken() else {
            return nil
        }
        return SessionInfo(loginIdToken: parsedToken)
    }

    /// Logs the user out of the current session.
    public func logout() {
        session.logout()
    }
}
