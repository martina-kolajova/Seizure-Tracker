//
//  KeychainManager.swift
//  EpiLog
//
//  Created by Martina Kolajová on 12.06.2026.
//
//  Secure Keychain wrapper for storing sensitive data (patient info, seizures).
//

import Foundation
import Security

/// KeychainManager provides secure storage for sensitive medical data.
/// Uses iOS Keychain with kSecClassGenericPassword class.
/// Data is protected with the device's encryption and accessible only to this app.
final class KeychainManager {
    
    static let shared = KeychainManager()
    
    private let serviceName = Bundle.main.bundleIdentifier ?? "com.kolajova.EpiLog"
    
    // MARK: - Save to Keychain
    /// Saves encoded data to Keychain under the specified key.
    func save(data: Data, forKey key: String) -> Bool {
        // Build the Keychain query
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Try to delete existing item first (avoids duplicate key errors)
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("❌ Keychain save failed for key '\(key)': \(status)")
            return false
        }
        
        print("✅ Data saved to Keychain: \(key)")
        return true
    }
    
    // MARK: - Load from Keychain
    /// Retrieves data from Keychain by key.
    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            if status != errSecItemNotFound {
                print("❌ Keychain load failed for key '\(key)': \(status)")
            }
            return nil
        }
        
        print("✅ Data loaded from Keychain: \(key)")
        return data
    }
    
    // MARK: - Delete from Keychain
    /// Removes data from Keychain by key.
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("❌ Keychain delete failed for key '\(key)': \(status)")
            return false
        }
        
        print("✅ Data deleted from Keychain: \(key)")
        return true
    }
    
    // MARK: - Delete All
    /// Removes all app-related data from Keychain (GDPR: user data wipe).
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("❌ Keychain deleteAll failed: \(status)")
            return false
        }
        
        print("✅ All Keychain data deleted for service: \(serviceName)")
        return true
    }
}
