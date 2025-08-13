//
//  MFAValidator.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import LoginIDAPIClient

/// Utility for validating and resolving the required payload
/// to perform specific Multi-Factor Authentication (MFA) actions.
final class MFAValidator {
    enum PasskeyOptions {
        case creation(PublicKeyCredentialCreationOptions)
        case request(PublicKeyCredentialRequestOptions)
    }
    
    /**
     Validates that all required information is present to perform the given MFA action,
     and resolves the payload to be used.
     
     This method will:
     1. Ensure a session is available (from either `options` or `info`).
     2. Use an explicit payload from `options` if provided.
     3. Otherwise, attempt to extract the payload from the provided `MFAInfo` for supported actions.
     4. Throw a `LoginIDError` if required information cannot be found.
     
     - Parameters:
       - action: The MFA action to perform (e.g., `.passkeyAuth`, `.otpSms`).
       - info: Optional `MFAInfo` object containing available factors and options.
       - options: Optional `PerformActionOptions` provided by the caller.
     
     - Returns: A fully populated `PerformActionOptions` instance.
     
     - Throws:
       - `LoginIDError` with `msgCode = "not_found"` if a session or payload is missing.
       - `LoginIDError` if no matching factor is found for the given action.
       ```
     */
    static public func actionValidator(
        action: MfaActionAction.Name,
        info: MFAInfo?,
        options: PerformActionOptions?
    ) throws -> ActionPayload {
        let session = options?.session ?? info?.session
        guard let session else {
            throw LoginIDError(
                msgCode: "not_found",
                msg: "A session is required to perform MFA factor.",
            )
        }

        if let payload = options?.payload, !payload.isEmpty {
            return ActionPayload(
                session: session,
                payload: payload,
            )
        }
        
        let canFindPayloadInInfo: Set<MfaActionAction.Name> = [
            .passkeyReg, .passkeyAuth, .passkeyTx, .otpEmail, .otpSms
        ]

        guard let next = info?.next, !next.isEmpty,
            canFindPayloadInInfo.contains(action)
        else {
            throw LoginIDError(
                msgCode: "not_found",
                msg: "Payload is required to perform MFA factor.",
            )
        }
        
        guard let factor = next.first(where: { $0.action.name == action }) else {
            throw LoginIDError(
                msgCode: "not_found",
                msg: "No matching factor found for \(action.rawValue).",
            )
        }
        
        let resolvedPayload: String
        switch action {
        case .passkeyReg, .passkeyAuth, .passkeyTx:
            resolvedPayload = try getFactorPayload(
                action: action,
                factor: factor
            )

        case .otpEmail:
            resolvedPayload = try getFactorPayload(
                action: action,
                factor: factor,
                key: "email:primary"
            )

        case .otpSms:
            resolvedPayload = try getFactorPayload(
                action: action,
                factor: factor
            )

        // Actions that must always be provided explicitly
        case .otpVerify, .external:
            throw LoginIDError(
                msgCode: "not_found",
                msg: "Payload is required to perform MFA factor.",
            )
        }

        return ActionPayload(
            session: session,
            payload: resolvedPayload,
        )
    }
    
    static public func validatePasskeyPayload(_ payload: String?) throws -> PasskeyOptions {
        guard let payload, !payload.isEmpty else {
            throw LoginIDError(
                msgCode: "not_found",
                msg: "Payload is required for passkeys",
            )
        }
        
        guard let jsonData = payload.decodeJWTOrPayloadSegment() else {
            throw LoginIDError(
                msgCode: "invalid_param",
                msg: "Invalid payload for passkey",
            )
        }
        
        if let creation = try? JSONCoding.decoder().decode(
            PublicKeyCredentialCreationOptions.self,
            from: jsonData
        ),
           creation.isValid {
            return .creation(creation)
        }
        
        if let request = try? JSONCoding.decoder().decode(
            PublicKeyCredentialRequestOptions.self,
            from: jsonData
        ),
           request.isValid {
            return .request(request)
        }
        
        throw LoginIDError(
            msgCode: "invalid_param",
            msg: "Invalid payload for passkey",
        )
    }
    
    /**
     Retrieves the payload for the given MFA factor, optionally filtering by key.
     
     - Parameters:
       - action: The MFA action being performed.
       - factor: The `MfaAction` from which to retrieve the payload.
       - key: For OTP actions, the contact key to match (e.g., `"email:primary"`). Defaults to `nil`.
     
     - Returns: The resolved payload value.
     
     - Throws:
       - `LoginIDError` with `msgCode = "not_found"` if no valid payload is found.
     */
    static private func getFactorPayload(
        action: MfaActionAction.Name,
        factor: MfaAction,
        key: String? = nil
    ) throws -> String {
        guard let options = factor.options, !options.isEmpty else {
            throw LoginIDError(
                msgCode: "not_found",
                msg:"Payload is required for \(action.rawValue).",
            )
        }

        let isPasskey: Set<MfaActionAction.Name> = [.passkeyReg, .passkeyAuth, .passkeyTx]
        if isPasskey.contains(action) {
            // Passkeys: take the first option's value
            if let value = options.first?.value, !value.isEmpty {
                return value
            }
            throw LoginIDError(
                msgCode: "not_found",
                msg: "Payload is required for \(action.rawValue).",
            )
        }

        // OTP flows: choose by key if provided, else first option's label
        if let key {
            if let match = options.first(where: { $0.name == key }), let label = match.label, !label.isEmpty {
                return label
            }
            throw LoginIDError(
                msgCode: "not_found",
                msg: "Contact is not found for \(action.rawValue).",
            )
        } else {
            if let label = options.first?.label, !label.isEmpty {
                return label
            }
            throw LoginIDError(
                msgCode: "not_found",
                msg: "Contact is not found for \(action.rawValue).",
            )
        }
    }
}
