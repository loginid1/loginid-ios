//
//  TaskHandler.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import AuthenticationServices

/// A utility for executing asynchronous tasks with centralized error handling,
/// mapping various error types into `LoginIDError` for consistent downstream processing.
enum TaskHandler {
    /**
     Executes an asynchronous task and normalizes any thrown errors
     into a `LoginIDError` when possible.
     
     This method handles the following error mappings:
     - `LoginIDError`: Re-thrown unchanged.
     - `ErrorResponse`: Converted using `LoginIDError.fromErrorResponse(from:)`.
     - `ASAuthorizationError`: Converted using `LoginIDError.fromErrorASAuthorization(from:)`.
     - `NSError`: Converted into `LoginIDError` with `msgCode = "client_error"`.
     - Any other error: Mapped to `.unknown`.
     
     - Parameter task: An asynchronous closure that may throw an error.
     - Returns: The value returned by the task if it succeeds.
     - Throws: A `LoginIDError` appropriate to the error encountered.
     */
    static func executeTask<T>(
        task: @escaping () async throws -> T
    ) async throws -> T {
        do {
            return try await task()
        } catch let error as LoginIDError {
            throw error
        } catch let error as ErrorResponse {
            throw LoginIDError.fromErrorResponse(from: error)
        } catch let error as ASAuthorizationError {
            throw LoginIDError.fromErrorASAuthorization(from: error)
        } catch let error as NSError {
            throw LoginIDError(msgCode: "client_error", msg: error.localizedDescription)
        } catch {
            throw LoginIDError.unknown
        }
    }
}
