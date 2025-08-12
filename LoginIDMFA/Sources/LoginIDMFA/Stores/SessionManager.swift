//
//  SessionManager.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

protocol SessionManaging {
    func logout()
}

final class SessionManager : SessionManaging {
    private let appId: String

    public init(appId: String) {
        self.appId = appId
    }

    private func tokenSetKey() -> String {
        return "LOGINID_MFA_SESSION_SET_\(appId)"
    }
    
    func logout() {
        _ = KeychainManager.removeItem(key: tokenSetKey())
    }
}
