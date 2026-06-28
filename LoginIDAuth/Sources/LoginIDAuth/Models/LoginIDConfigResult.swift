//
//  LoginIDConfigResult.swift
//  LoginIDAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import Foundation

/// Represents the result of a configuration verification check.
///
/// If `verifyConfigSettings()` returns a non-nil value, it indicates a configuration
/// problem that needs to be addressed.
public struct LoginIDConfigResult {
    /// A suggested solution to fix the configuration issue.
    public let solution: String
    
    /// A machine-readable error code.
    public let code: String
    
    /// A human-readable error message describing the issue.
    public let errorMessage: String
    
    /// Initializes a configuration result with details about the issue.
    /// - Parameters:
    ///   - solution: A suggested solution.
    ///   - code: An error code.
    ///   - errorMessage: A descriptive error message.
    public init(solution: String, code: String, errorMessage: String) {
        self.solution = solution
        self.code = code
        self.errorMessage = errorMessage
    }
}
