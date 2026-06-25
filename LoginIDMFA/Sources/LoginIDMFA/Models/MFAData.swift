//
//  MFAData.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-06-23.
//

import LoginIDAPIClient
import LoginIDCore

/// An extended set of tokens obtained upon login, with optional authentication details.
public struct MFAData {
    /// A collection of authentication tokens returned after a successful login.
    let tokenSet: TokenSet
    
    /// Represents additional information about a passkey.
    let passkeyInfo: PasskeyInfo?
    
    init(result: Mfa) {
        self.tokenSet = TokenSet(result: result)
        self.passkeyInfo = result.passkeyInfo.map { PasskeyInfo(from: $0) }
    }
}
