//
//  LoginID.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-07-31.
//

import Foundation
import LoginIDAPIClient

public class LoginID: NSObject {
    private let trustId: TrustIDManaging
    private let session: SessionManaging
    private let config: LoginIDConfig
    private let store: MFAStore
    private let mfa: MFA
    
    public init(baseUrl: String) {
        config = LoginIDConfig(baseUrl: baseUrl)
        
        OpenAPIClientAPIConfiguration.shared.basePath = baseUrl
        
        let appId = config.getAppIdOrEmpty()
        
        store = MFAStore(appId: appId)
        session = SessionManager(appId: appId)
        trustId = TrustID()
        mfa = MFA(config: config, store: store, trustId: trustId)
    }
    
    public init(config: LoginIDConfig) {
        self.config = config
        
        let appId = config.getAppIdOrEmpty()
        
        store = MFAStore(appId: appId)
        session = SessionManager(appId: appId)
        trustId = TrustID()
        mfa = MFA(config: config, store: store, trustId: trustId)
    }
}
