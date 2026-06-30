//
//  ClientEventsService.swift
//  LoginIDMFA
//
//  Created by LoginID on 2026-06-24.
//

import AuthenticationServices
import Foundation

/// A service responsible for handling client-side events and analytics.
public struct ClientEventsService: LoginIDClientEventsAPI {
    /// Configuration for LoginID services.
    private let config: LoginIDConfig

    /**
     Initializes the `ClientEventsService`.
     
     - Parameters:
       - config: The `LoginIDConfig` containing configuration details like the base URL.
       - clientEventsAPI: The API client to use for submitting events. Defaults to `ClientEventsAPI`.
       - apiConfiguration: The configuration for the API request. If not provided, the shared global one will be used..
     */
    public init(config: LoginIDConfig) {
        self.config = config
    }
    
    /**
     Submits an `ASAuthorizationError` as a client-side event.
     
     If the provided error is not an `ASAuthorizationError`, this method does nothing and returns the provided session.
     
     - Parameters:
       - error: The error to be submitted.
       - session: An optional session string to include for authorization.
     - Throws: An error if the event submission fails.
     - Returns: An optional new session string from the server response.
     */
    public func submitASAuthorizationErrorEvent(error: Error, session: String?) async throws -> String? {
        guard !config.disableAnalytics, let authError = error as? ASAuthorizationError else {
            return nil
        }
        
        let loginIDError = LoginIDError.fromErrorASAuthorization(from: authError)
        let message = "\(loginIDError.msgCode) - \(loginIDError.msg) - ASAuthorizationError - \(authError.code) - \(authError.errorCode)"
        
        return try await submitEvent(message: message, session: session)
    }
    
    private func submitEvent(message: String, session: String?) async throws -> String? {
        let requestBody = SubmitRequestBody(event: message, isError: true)
        
        let response = try await ClientEventsAPI.clientEventsSubmit(
            submitRequestBody: requestBody,
            authorization: session,
        )
        
        return response.session
    }
}
