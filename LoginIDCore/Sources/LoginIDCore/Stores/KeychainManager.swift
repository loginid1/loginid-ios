//
//  KeychainManager.swift
//  Core
//
//  Created by Michael Braga on 2025-08-14.
//

import Security
import Foundation

/// A utility class for storing, retrieving, and deleting small pieces of secure data
/// in the iOS Keychain. Supports storing generic password items keyed by account name.
public class KeychainManager {
    /**
     Stores a data item in the Keychain under the specified key.
     
     If an item with the same key already exists, it will be deleted before adding the new one.
     
     - Parameters:
       - key: The unique account identifier (used as `kSecAttrAccount`) for the stored item.
       - data: The raw `Data` to store securely.
     - Returns: An `OSStatus` result code. A value of `errSecSuccess` (0) indicates success.
     */
    public static func setItem(key: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]

        // Delete item first if it already exists
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    /**
     Retrieves a data item from the Keychain for the given key.
     
     - Parameter key: The unique account identifier (used as `kSecAttrAccount`) for the stored item.
     - Returns: The stored `Data` if found, otherwise `nil`.
     */
    public static func getItem(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }

    /**
     Removes a data item from the Keychain for the given key.
     
     - Parameter key: The unique account identifier (used as `kSecAttrAccount`) for the stored item.
     - Returns: An `OSStatus` result code. A value of `errSecSuccess` (0) indicates success.
     */
    public static func removeItem(key: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]

        return SecItemDelete(query as CFDictionary)
    }
}
