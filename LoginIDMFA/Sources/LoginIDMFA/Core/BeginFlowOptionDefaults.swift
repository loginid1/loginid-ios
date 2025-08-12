//
//  BeginFlowOptionDefaults.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDAPIClient

final class BeginFlowOptionDefaults {
    private let options: BeginFlowOptions?
    private let username: String

    public init(username: String, options: BeginFlowOptions?) {
        self.username = username
        self.options = options
    }
    
    var displayName: String {
        return options?.displayName?.isEmpty == false ? options!.displayName! : username
    }
    
    var usernameType: User.UsernameType {
        return options?.usernameType ?? .other
    }
    
    var txPayload: String? {
        return options?.txPayload
    }
    
    var checkoutId: String? {
        return options?.checkoutId
    }
    
    var traceId: String? {
        return options?.traceId
    }
    
    var user: User {
        return User(
            displayName: displayName,
            username: username,
            usernameType: usernameType,
        )
    }
}
