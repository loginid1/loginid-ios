//
//  ClientEventsAPIProtocol.swift
//  LoginIDMFA
//
//  Created by LoginID on 2026-06-24.
//

import LoginIDCore

/// A protocol that defines the interface for the `ClientEventsAPI`.
/// This protocol is used to enable dependency injection and testing of the `ClientEventsAPI`.
protocol ClientEventsAPIProtocol {
    /**
     Submits a client-side event to the LoginID service.
     
     - Parameters:
       - submitRequestBody: The body of the request, containing the event details.
       - authorization: An optional JWT for authorization.
       - apiConfiguration: The configuration for the API request.
     - Throws: An error if the request fails.
     - Returns: A `Session` object upon success.
     */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    static func clientEventsSubmit(
        submitRequestBody: SubmitRequestBody,
        authorization: String?,
        apiConfiguration: OpenAPIClientAPIConfiguration
    ) async throws -> Session
}
