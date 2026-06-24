//
//  ClientEventsServiceProtocol.swift
//  LoginIDMFA
//
//  Created by LoginID on 2026-06-24.
//

import Foundation
import LoginIDCore
import LoginIDAPIClient

/// A protocol that defines the interface for submitting client-side events.
protocol ClientEventsServiceProtocol: Sendable {
    /**
     Submits an `ASAuthorizationError` as a client-side event.
     
     If the provided error is not an `ASAuthorizationError`, this method does nothing and returns the provided session.
     
     - Parameters:
       - error: The error to be submitted.
       - session: An optional session string to include for authorization.
     - Throws: An error if the event submission fails.
     - Returns: An optional new session string from the server response.
     */
    func submitASAuthorizationErrorEvent(error: Error, session: String?) async throws -> String?
}
