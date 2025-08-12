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
        options: BeginFlowOptions?
    ) async throws -> Void {
        let appId = try config.getAppId()
        let deviceId = store.getDeviceId()
        let deviceInfo = await DeviceUtils.getDeviceInfo(deviceId: deviceId)
        let values = BeginFlowOptionDefaults(username: username, options: options)
        
        let walletTrustId = ""
    }
}
