//
//  MFASessionResult.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

import LoginIDAPIClient

/// Represents the result of a Multi-Factor Authentication (MFA) session.
///
/// This structure is used to track the status of an ongoing MFA process, including
/// remaining factors, user details, and issued authentication tokens.
public struct MFASessionResult {
    /// The MFA flow type indicating whether the session is part of sign-in or sign-up.
    /// This helps differentiate between authentication scenarios.
    let flow: MfaNext.Flow?
    
    /// List of MFA factors that still need to be completed for authentication.
    /// If this list is empty, the authentication process is complete.
    let remainingFactors: [RemainingAction]
    
    /// The username associated with the authentication session.
    /// This may be `nil` if not provided or applicable.
    let username: String?
    
    /// Indicates whether the MFA session is complete.
    /// If `true`, all required factors have been successfully validated.
    let isComplete: Bool
    
    /// The MFA state session.
    /// This should be obtained from a previous MFA request or initiation step.
    let session: String?
    
    /// A JSON Web Token (JWT) issued upon successful authentication.
    /// Used to verify user identity and grant access to protected resources.
    let idToken: String?
    
    /// A JSON Web Token (JWT) used for authorizing API requests.
    /// This token grants access to user-specific resources and actions.
    let accessToken: String?
    
    /// A token used to obtain new access and ID tokens after expiration.
    /// This helps maintain user sessions without requiring re-authentication.
    let refreshToken: String?
    
    /// A JSON Web Signature (JWS) that provides cryptographic proof of the payload's integrity.
    /// Ensures that the authentication data has not been tampered with.
    let payloadSignature: String?
    
    /// The next recommended MFA factor action to take.
    /// Indicates which MFA factor the user should complete next in order to proceed.
    let nextAction: MfaActionAction.Name?
    
    public init(info: MFAInfo?, tokenSet: TokenSet?) {
        self.flow = info?.flow
        self.username = info?.username
        self.session = info?.session
        self.idToken = tokenSet?.idToken
        self.accessToken = tokenSet?.accessToken
        self.refreshToken = tokenSet?.refreshToken
        self.payloadSignature = tokenSet?.payloadSignature
        self.isComplete = (tokenSet?.accessToken != nil) || (tokenSet?.payloadSignature != nil)
        
        let priority: [MfaActionAction.Name] = [
            .passkeyReg, .passkeyAuth, .passkeyTx, .otpSms, .otpEmail, .external
        ]
        
        let available: [MfaActionAction.Name] = info?.next?.map { $0.action.name } ?? []
        
        self.nextAction = available.firstMatch(in: priority)
        
        self.remainingFactors = (info?.next ?? []).map { factor in
            let action = factor.action

            let options: [String]? = {
                guard let opts = factor.options else { return nil }
                if action.name == .otpSms || action.name == .otpEmail {
                    let labels = opts.compactMap { $0.label }.filter { !$0.isEmpty }
                    return labels.isEmpty ? nil : labels
                }
                return nil
            }()

            let value: String? = {
                guard let opts = factor.options else { return nil }
                switch action.name {
                case .passkeyReg, .passkeyAuth, .passkeyTx:
                    return opts.first(where: { !$0.value.isEmpty })?.value
                default:
                    return nil
                }
            }()

            return RemainingAction(
                type: action.name,
                label: action.label,
                description: action.desc,
                value: value,
                options: options,
            )
        }
    }
}
