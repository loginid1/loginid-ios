//
//  LoginIDError.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-07-31.
//

import AuthenticationServices

/// Represents a standardized error used across LoginID MFA.
/// Provides error codes and user-readable messages for decoding and authorization errors.
public final class LoginIDError: NSObject, Error, Codable {
    public let msgCode: String
    public let msg: String
    public let message: String

    /// A generic fallback error.
    public static let unknown: LoginIDError = .init(
        msgCode: "unknown_error",
        msg: "unknown error",
        message: "unknown error"
    )

    /// Error representing a failed passkey authentication.
    public static let failedAuthentication: LoginIDError = .init(
        msgCode: "passkey_authentication_failed",
        msg: "Failed to authenticate with passkey"
    )

    /// Creates a `LoginIDError` instance from a given `ErrorResponse`.
    ///
    /// - Parameter errorResponse: The error response returned from an API call.
    /// - Returns: A parsed `LoginIDError` or `.unknown` if parsing fails.
    static func fromErrorResponse(from errorResponse: ErrorResponse) -> LoginIDError {
        guard
            case let ErrorResponse.error(_, data?, _, error) = errorResponse
        else {
            return LoginIDError.unknown
        }

        if let decodingError = error as? DecodingError {
            return handleDecodingError(decodingError)
        }

        if let errorData = try? JSONDecoder().decode(LoginIDError.self, from: data) {
            return errorData
        }

        return LoginIDError.unknown
    }

    /// Converts an `ASAuthorizationError` to a `LoginIDError`.
    ///
    /// - Parameter error: The `ASAuthorizationError` instance to convert.
    /// - Returns: A mapped `LoginIDError`.
    static func fromErrorASAuthorization(from error: ASAuthorizationError) -> LoginIDError {
         if #available(iOS 18, *), error.code == ASAuthorizationError.matchedExcludedCredential {
             return LoginIDError(
                 msgCode: "auth_passkey_exists",
                 msg: "A passkey already exists on your device"
             )
         }
        
        if #available(iOS 15, *), error.code == ASAuthorizationError.notInteractive {
            return LoginIDError(
                msgCode: "auth_error_not_interactive",
                msg: "Authorization process was not interactive."
            )
        }

        switch error {
        case ASAuthorizationError.canceled:
            return LoginIDError(
                msgCode: "auth_error_canceled",
                msg: "Authorization was canceled by the user."
            )

        case ASAuthorizationError.failed:
            return LoginIDError(
                msgCode: "auth_error_failed",
                msg: "Authorization failed due to an unknown error."
            )

        case ASAuthorizationError.invalidResponse:
            return LoginIDError(
                msgCode: "auth_error_invalid_response",
                msg: "The authorization response was invalid."
            )

        case ASAuthorizationError.notHandled:
            return LoginIDError(
                msgCode: "auth_error_not_handled",
                msg: "Authorization request was not handled."
            )

        case ASAuthorizationError.unknown:
            return LoginIDError(
                msgCode: "auth_error_unknown",
                msg: "An unknown authorization error occurred."
            )

        default:
            return LoginIDError(
                msgCode: "passkey_error",
                msg: "An Unknown authorization error"
            )
        }
    }

    /// Converts a `DecodingError` to a structured `LoginIDError`.
    ///
    /// - Parameter error: The decoding error encountered.
    /// - Returns: A user-readable `LoginIDError`.
    static func handleDecodingError(_ error: DecodingError) -> LoginIDError {
        switch error {
        case let .dataCorrupted(context):
            return LoginIDError(
                msgCode: "decode_error",
                msg: "Data corrupted: \(context.debugDescription)"
            )

        case let .keyNotFound(key, context):
            return LoginIDError(
                msgCode: "decode_error",
                msg: "Key '\(key)' not found: \(context.debugDescription)"
            )

        case let .typeMismatch(type, context):
            return LoginIDError(
                msgCode: "decode_error",
                msg: "Type mismatch for \(type): \(context.debugDescription)"
            )

        case let .valueNotFound(type, context):
            return LoginIDError(
                msgCode: "decode_error",
                msg: "Value not found for \(type): \(context.debugDescription)"
            )

        @unknown default:
            return LoginIDError(
                msgCode: "decode_error",
                msg: "Unknown decoding error"
            )
        }
    }

    /// Creates a `LoginIDError` when an enum value is invalid.
    ///
    /// - Parameters:
    ///   - invalidValue: The unexpected raw value encountered.
    ///   - enumType: The enum type for which the value is invalid.
    /// - Returns: A `LoginIDError` describing the allowed values.
    static func fromEnum<T: RawRepresentable & CaseIterable>(
        invalidValue: T.RawValue,
        enumType: T.Type
    ) -> LoginIDError where T.RawValue == String {
        let validValues = enumType.allCases.map { $0.rawValue }.joined(separator: ", ")
        let msg = "'\(invalidValue)' is not valid. Valid values are: \(validValues)"
        return LoginIDError(msgCode: "invalid_param", msg: msg)
    }

    /// Initializes a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if decoding fails.
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedMsgCode = try container.decodeIfPresent(String.self, forKey: .msgCode) ?? "unknown_error"
        let decodedMsg = try container.decodeIfPresent(String.self, forKey: .msg) ?? ""
        let decodedMessage = try container.decodeIfPresent(String.self, forKey: .message) ?? ""

        let finalMessage: String
        let finalMsg: String

        if decodedMessage.isEmpty && decodedMsg.isEmpty {
            finalMessage = "Unknown error"
            finalMsg = "Unknown error"
        } else if !decodedMsg.isEmpty {
            finalMessage = decodedMsg
            finalMsg = decodedMsg
        } else {
            finalMessage = decodedMessage
            finalMsg = decodedMessage
        }

        self.msgCode = decodedMsgCode
        self.msg = finalMsg
        self.message = finalMessage
    }

    enum CodingKeys: String, CodingKey {
        case msgCode
        case msg
        case message
    }

    /// Initializes a `LoginIDError` with explicit code, message, and detailed message.
    ///
    /// - Parameters:
    ///   - msgCode: A machine-readable error code.
    ///   - msg: A short user-facing error message.
    ///   - message: A longer, optional description.
    public init(msgCode: String, msg: String, message: String) {
        self.msgCode = msgCode
        self.msg = msg
        self.message = message
    }

    /// Initializes a `LoginIDError` with code and message. Message is reused as the detailed message.
    ///
    /// - Parameters:
    ///   - msgCode: A machine-readable error code.
    ///   - msg: A user-facing error message.
    public init(msgCode: String, msg: String) {
        self.msgCode = msgCode
        self.msg = msg
        message = msg
    }
}
