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
     Stores a data item in the Keychain under the specified service and account.

     If an item with the same service/account combination already exists,
     it will be deleted before adding the new one.

     - Parameters:
       - service: The Keychain service identifier (`kSecAttrService`) used to group related items.
       - account: The account identifier (`kSecAttrAccount`) for the stored item.
       - data: The raw `Data` to store securely.
     - Returns: An `OSStatus` result code. A value of `errSecSuccess` (0) indicates success.
     */
    public static func setItem(service: String, account: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
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
     Retrieves a data item from the Keychain for the specified service and account.

     - Parameters:
       - service: The Keychain service identifier (`kSecAttrService`) associated with the item.
       - account: The account identifier (`kSecAttrAccount`) associated with the item.
     - Returns: The stored `Data` if found, otherwise `nil`.
     */
    public static func getItem(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
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
     Retrieves all Keychain items associated with the specified service.

     The returned dictionaries contain the item's attributes and data as provided
     by the Keychain Services API.

     - Parameter service: The Keychain service identifier (`kSecAttrService`) used to filter items.
     - Returns: An array of item dictionaries if matching items are found, otherwise `nil`.
     */
    public static func getAllItems(service: String) -> [[String: Any]]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == noErr {
            return item as? [[String: Any]]
        }

        return nil
    }

    /**
     Updates the data for an existing Keychain item matching the specified
     service and account.

     The item must already exist in the Keychain. If no matching item is found,
     the returned status will indicate the failure reason (for example,
     `errSecItemNotFound`).

     - Parameters:
       - service: The Keychain service identifier (`kSecAttrService`) associated with the item.
       - account: The account identifier (`kSecAttrAccount`) associated with the item.
       - data: The new `Data` value to store.
     - Returns: An `OSStatus` result code. A value of `errSecSuccess` (0) indicates success.
     */
    public static func updateItem(service: String, account: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
        ]

        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
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
    
    /**
     Removes all Keychain items associated with the specified service.

     - Parameter service: The Keychain service identifier (`kSecAttrService`) whose items should be removed.
     - Returns: An `OSStatus` result code. A value of `errSecSuccess` (0) indicates success.
     */
    public static func removeAllItems(service: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]

        return SecItemDelete(query as CFDictionary)
    }
}
