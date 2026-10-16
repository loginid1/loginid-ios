//
//  RegInit+ApplyOverrides.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-10-16.
//

public extension RegInit {
    /// Returns a copy of the RegInit response with any client-supplied overrides applied.
    ///
    /// - Parameter deviceDisplayName: When non-empty, replaces the `name` and `displayName`
    ///   of the registration user entity shown by the authenticator. Otherwise the response is left untouched.
    /// - Returns: The RegInit response, with overrides applied when defined.
    func applyingOverrides(deviceDisplayName: String? = nil) -> RegInit {
        guard let deviceDisplayName, !deviceDisplayName.isEmpty else {
            return self
        }

        var copy = self
        copy.registrationRequestOptions.user.name = deviceDisplayName
        copy.registrationRequestOptions.user.displayName = deviceDisplayName
        return copy
    }
}
