//
//  TrustTokenFinder.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2026-06-23.
//

import LoginIDCore

// A utility structure for locating trust tokens within a Mfa Begin response.
internal struct TrustTokenFinder {
    private static let MERCHANT_TRUST_ID = "merchantTrustID"
    private static let WALLET_TRUST_ID = "walletTrustID"

    /**
     Finds trust tokens from an MFA `next` action.

     - Parameter result: The result from an MFA authentication step.
     - Returns: A `TrustSet` containing found tokens, or `nil`.
     */
    static func findTrustTokens(result: MfaNext) -> TrustSet? {
        guard let passkeyAction = result.next?.first(where: {
            $0.action.name.rawValue.starts(with: "passkey:")
        }) else {
            return nil
        }

        guard let options = passkeyAction.options else {
            return nil
        }

        let merchantTrustId = options.first { $0.name == MERCHANT_TRUST_ID }?.value
        let walletTrustId = options.first { $0.name == WALLET_TRUST_ID }?.value

        if merchantTrustId == nil, walletTrustId == nil {
            return nil
        }

        return TrustSet(merchantTrustId: merchantTrustId, walletTrustId: walletTrustId)
    }
}
