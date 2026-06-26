//
//  ErrorResponse.swift
//  Core
//
//  Created by Michael Braga on 2025-08-14.
//

import Foundation

/// A general-purpose error wrapper for HTTP response failures.
///
/// This enum is used to encapsulate server-side errors, decoding failures, or
/// other issues encountered during a network request.
public enum ErrorResponsee: Error {
    /// Represents an HTTP error response.
    ///
    /// - Parameters:
    ///   - Int: The HTTP status code.
    ///   - Data?: The optional response body data.
    ///   - URLResponse?: The original URL response object.
    ///   - Error: The underlying error that occurred (e.g., decoding or transport error).
    case error(Int, Data?, URLResponse?, Error)
}
