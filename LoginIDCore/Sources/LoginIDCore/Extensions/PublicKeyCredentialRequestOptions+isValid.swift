//
//  PublicKeyCredentialRequestOptions+isValid.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-26.
//

extension PublicKeyCredentialRequestOptions {
    public var isValid: Bool {
        rpId?.isEmpty == false &&
        !challenge.isEmpty &&
        allowCredentials?.isEmpty == false
    }
}
