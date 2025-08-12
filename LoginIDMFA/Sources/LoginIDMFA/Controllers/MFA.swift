//
//  MFA.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

class MFA {
    private let trustId: TrustIDManaging
    private let config: LoginIDConfig
    private let store: MFAStoring
    
    public init(config: LoginIDConfig, store: MFAStoring, trustId: TrustIDManaging) {
        self.config = config
        self.store = store
        self.trustId = trustId
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
        
        var walletTrustId: String? = nil
        if values.txPayload != nil {
            walletTrustId = try trustId.signWithTrustId()
        }
    }
}
