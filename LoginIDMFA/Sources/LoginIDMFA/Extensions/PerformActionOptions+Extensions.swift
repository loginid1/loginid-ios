//
//  PerformActionOptions+Extensions.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-09-10.
//

internal extension PerformActionOptions {
    /// Returns a copy of this instance with all the same fields,
    /// except `txPayload` is always `nil`.
    ///
    /// - Returns: A new `PerformActionOptions` instance identical to `self`,
    ///   but with `txPayload` set to `nil`.
    func withoutTxPayload() -> PerformActionOptions {
        return PerformActionOptions(
            session: self.session,
            payload: self.payload,
            autoFill: self.autoFill,
            displayName: self.displayName,
            txPayload: nil
        )
    }
}
