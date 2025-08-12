//
//  MFA.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

class MFA {
    private let config: LoginIDConfig
    private let store: MFAStoring
    
    public init(config: LoginIDConfig, store: MFAStoring) {
        self.config = config
        self.store = store
    }
    
    @available(iOS 16.0, *)
    public func beginFlow(
        username: String,
        options: MfaBeginOptions?
    ) async throws -> Void {
        let appId = try config.getAppId()
        let deviceId = store.getDeviceId()
    }
}
