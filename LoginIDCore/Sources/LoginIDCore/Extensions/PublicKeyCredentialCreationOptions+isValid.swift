//
//  PublicKeyCredentialCreationOptions+isValid.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-26.
//

extension PublicKeyCredentialCreationOptions {
    public init(
        options: PublicKeyCredentialCreationOptions,
        username: String
    ) {
        self = options
        self.user = PublicKeyCredentialUserEntity(
            displayName: options.user.displayName,
            id: options.user.id,
            name: username,
        )
    }

    public var isValid: Bool {
        rp.id?.isEmpty == false &&
        challenge.isEmpty == false &&
        user.id.isEmpty == false
    }
}
