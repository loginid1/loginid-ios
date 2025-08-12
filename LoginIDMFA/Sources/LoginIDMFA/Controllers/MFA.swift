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
    ) async throws -> MFASessionResult {
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
        
        session.logout()
        store.storeMFAInfo(info)
        
        return MFASessionResult(info: info, tokenSet: nil)
    }
    
    public func performAction(
        action: MfaActionAction.Name,
        options: PerformActionOptions?,
    ) async throws -> MFASessionResult {
        let appId = try config.getAppId()
        let info = store.getMFAInfo()
        let values = try MFAValidator.actionValidator(action: action, info: info, options: options)
        
        switch action {
        case .passkeyReg, .passkeyAuth, .passkeyTx:
            print("wow")
            
            throw LoginIDError(
                msgCode: "",
                msg: "MFA factor \(action) is not supported in the current MFA flow."
            )
        case .external:
            return try await invokeMfaApi(appId: appId, username: info?.username) {
                let requestBody = MfaThirdPartyAuthVerifyRequestBody(token: values.payload)
                return try await MfaAPI.mfaMfaThirdPartyAuthVerify(
                    mfaThirdPartyAuthVerifyRequestBody: requestBody,
                    authorization: values.session,
                )
            }
            
        default:
            throw LoginIDError(
                msgCode: "",
                msg: "MFA factor \(action) is not supported in the current MFA flow."
            )
        }
    }
    
    private func invokeMfaApi(
        appId: String,
        username: String?,
        _ fn: () async throws -> Mfa
    ) async throws -> MFASessionResult {
        do {
            let performActionResult = try await fn()
            let info = store.getMFAInfo()
            let successInfo = MFAInfo(username: username, flow: info?.flow)
            let tokenSet = TokenSet(result: performActionResult)
            
            store.storeMFAInfo(successInfo)
            store.storeDeviceId(performActionResult.deviceId)
            session.setTokenSet(tokenSet)
            
            return MFASessionResult(info: info, tokenSet: tokenSet)
        } catch let ErrorResponse.error(status, data, urlResponse, underlying)  {
            if status == 401,
               let data = data,
               let result = try? JSONCoding.decoder().decode(MfaNext.self, from: data),
               let session = result.session
            {
                let current = store.getMFAInfo()
                let info = MFAInfo(result: result, username: username)
                
                store.storeMFAInfo(info)
                
                return MFASessionResult(info: info, tokenSet: nil)
            }
            
            //TODO: Add client-events here after if it got here which means true error
            
            // Rethrow same error. Global TaskHandler should catch it.
            throw ErrorResponse.error(status, data, nil, underlying)
        } catch {
            throw error
        }
    }
}
