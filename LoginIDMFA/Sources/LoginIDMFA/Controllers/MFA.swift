//
//  MFA.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDAPIClient

final class MFA {
    private let trustId: TrustIDManaging
    private let session: SessionManaging
    private let config: LoginIDConfig
    private let store: MFAStoring
    
    public init(
        config: LoginIDConfig,
        store: MFAStoring,
        session: SessionManaging,
        trustId: TrustIDManaging
    ) {
        self.config = config
        self.store = store
        self.session = session
        self.trustId = trustId
    }
    
    public func beginFlow(
        username: String,
        options: BeginFlowOptions?
    ) async throws -> MfaSessionResult {
        let appId = try config.getAppId()
        let deviceId = store.getDeviceId()
        let deviceInfo = await DeviceUtils.getDeviceInfo(deviceId: deviceId)
        let values = BeginFlowOptionDefaults(username: username, options: options)
        
        var walletTrustId: String? = nil
        if values.txPayload != nil {
            walletTrustId = try trustId.signWithTrustId()
        }
        
        let mfaBeginRequestBody = MfaBeginRequestBody(
            deviceInfo: deviceInfo,
            payload: values.txPayload,
            traceId: values.traceId,
            trustItems: [
                "wallet": walletTrustId ?? "",
                "merchant": values.checkoutId ?? "",
            ],
            user: values.user,
        )
        
        let mfaNextResult = try await MfaAPI.mfaMfaBegin(
            // Already supplied by device info
            userAgent: "",
            mfaBeginRequestBody: mfaBeginRequestBody,
        )
        
        let info = MFAInfo(result: mfaNextResult, username: username)
        
        store.storeMFAInfo(info)
        
        session.logout()
        
        return MfaSessionResult(info: info, tokenSet: nil)
    }
}
