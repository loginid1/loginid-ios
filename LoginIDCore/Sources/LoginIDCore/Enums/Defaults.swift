//
//  Defaults.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-25.
//

import Foundation

public enum Defaults {
    public static func displayName(_ value: String?, username: String) -> String {
        return value?.isEmpty == false ? value! : username
    }
    
    public static func usernameType(_ value: UsernameType?) -> String {
        return value?.rawValue ?? "other"
    }
    
    public static func nonce(_ value: String?) -> String {
        return value?.isEmpty == false ? value! : UUID().uuidString
    }
    
    public static func txType(_ value: String?) -> String {
        return value?.isEmpty == false ? value! : "raw"
    }
    
    public static func autoFill(_ value: Bool?) -> Bool {
        return value ?? false
    }
    
    /// A `User` object constructed from the current values.
    public static func user(
        displayName: String?,
        username: String?,
        usernameType: UsernameType?
    ) -> User {
        return User(
            displayName: Defaults.displayName(displayName, username: username ?? ""),
            username: username ?? "",
            usernameType: Defaults.usernameType(usernameType)
        )
    }
    
    public static func userLogin(
        displayName: String?,
        username: String?,
        usernameType: UsernameType?
    ) -> UserLogin {
        return UserLogin(
            username: username ?? "",
            usernameType: Defaults.usernameType(usernameType)
        )
    }
    
    public static func deviceInfo(
        store: DeviceStoring,
        deviceId: String?
    ) async -> DeviceInfo {
        return await DeviceUtils.getDeviceInfo(
            deviceId: deviceId ?? store.getDeviceId()
        )
    }

    public static func trustItems(
        config: LoginIDConfig,
        store: TrustIDManaging,
        txPayload: String? = nil,
        merchantTrustId: String? = nil,
        username: String
    ) throws -> [String: String] {
        let walletId: String
        if txPayload != nil {
            walletId = try store.signWithTrustId()
        } else {
            walletId = ""
        }

        let merchantId = merchantTrustId ?? ""

        let authId: String
        if config.useTrustId, walletId.isEmpty, merchantId.isEmpty, !username.isEmpty {
            authId = try store.signWithTrustId(username: username)
        } else {
            authId = ""
        }

        return [
            "auth": authId,
            "wallet": walletId,
            "merchant": merchantId,
        ]
    }
}
