// ArtiusIDSDKWrapper.swift
// iOS-only wrapper for ArtiusID SDK binary framework
// Optimized for iPhone and iPad devices
// Created by Curtis Elswick on 07/07/2025

import Foundation
import UIKit           // Direct import - iPhone and iPad only
import Security        // For keychain operations

// Conditional Firebase imports - client flexibility maintained
#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

// Import OpenSSL for cryptographic operations (required by XCFramework)
#if canImport(OpenSSL)
import OpenSSL
#endif

// Re-export the binary framework (iPhone and iPad only)
@_exported import artiusid_sdk_ios

/// Simple Keychain wrapper for FCM token storage
/// This mimics the KeychainHelper used internally in the SDK
private class Keychain {
    private let service: String
    
    init(service: String = "com.artiusid.sdk") {
        self.service = service
    }
    
    func set(_ value: String, forKey key: String) -> Bool {
        let data = value.data(using: .utf8)!
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    func get(forKey key: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return String(data: dataTypeRef as! Data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    func delete(forKey key: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ] as [String: Any]
        
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}

/// Enhanced ArtiusID SDK Wrapper for iPhone and iPad
/// Provides seamless integration with optional Firebase support
public class ArtiusIDSDKWrapper {
    
    public static let shared = ArtiusIDSDKWrapper()
    
    private let keychain = Keychain()
    private var isFirebaseConfigured = false
    
    private init() {}
    
    // MARK: - Core SDK Interface
    
    /// Initialize the ArtiusID SDK with enhanced wrapper features
    public func configure() {
        // Configure Firebase integration if available
        configureFirebaseIfAvailable()
        
        print("[ArtiusIDSDKWrapper] v1.0.20 initialized for iPhone and iPad")
    }
    
    /// Update FCM token securely in keychain
    public func updateFCMToken(_ token: String) {
        _ = keychain.set(token, forKey: "fcm_token")
        print("[ArtiusIDSDKWrapper] FCM token updated securely")
    }
    
    /// Get current FCM token from secure storage
    public func getCurrentFCMToken() -> String? {
        return keychain.get(forKey: "fcm_token")
    }
    
    /// Get comprehensive SDK and integration information
    public func getSDKInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        
        // SDK version information
        info["sdkVersion"] = ArtiusIDSDKInfo.version
        info["wrapperVersion"] = "1.0.21"
        info["platform"] = "iPhone/iPad"
        info["architecture"] = ArtiusIDSDKInfo.architecture
        
        // Firebase integration status
        #if canImport(FirebaseCore)
        info["firebaseAvailable"] = true
        info["firebaseConfigured"] = isFirebaseConfigured
        #else
        info["firebaseAvailable"] = false
        info["firebaseConfigured"] = false
        #endif
        
        // Token availability
        info["fcmTokenAvailable"] = getCurrentFCMToken() != nil
        
        return info
    }
    
    // MARK: - Private Implementation
    
    /// Configure Firebase integration if available
    private func configureFirebaseIfAvailable() {
        #if canImport(FirebaseCore)
        // Check if Firebase is already configured by client app
        if FirebaseApp.app() != nil {
            isFirebaseConfigured = true
            setupFCMTokenHandling()
            print("[ArtiusIDSDKWrapper] Firebase integration enabled")
        } else {
            print("[ArtiusIDSDKWrapper] Firebase available but not configured by client app")
        }
        #else
        print("[ArtiusIDSDKWrapper] Firebase not available - operating in standalone mode")
        #endif
    }
    
    /// Setup FCM token refresh handling
    private func setupFCMTokenHandling() {
        #if canImport(FirebaseMessaging)
        // Listen for token refresh
        NotificationCenter.default.addObserver(
            forName: .MessagingRegistrationTokenRefreshed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Messaging.messaging().token { token, error in
                if let token = token {
                    self?.updateFCMToken(token)
                }
            }
        }
        
        // Get initial token
        Messaging.messaging().token { [weak self] token, error in
            if let token = token {
                self?.updateFCMToken(token)
            }
        }
        #endif
    }
}

/// SDK Information and utilities
public struct ArtiusIDSDKInfo {
    public static let version = "1.0.25"
    public static let build = "iOS Universal Binary (Device + Simulator)"
    public static let architecture = "iOS (arm64 + x86_64)"
    
    public static func printInfo() {
        print("ArtiusID SDK v\(version) (\(build)) - \(architecture)")
        print("Wrapper: iPhone and iPad optimized with Firebase integration")
        print("Production size: ~30MB (device slice only)")
    }
}

// MARK: - Public Convenience API

/// Main SDK access point - use this in your client code
public typealias ArtiusID = ArtiusIDSDKWrapper

/// Quick configuration method
public func configureArtiusIDSDK() {
    ArtiusIDSDKWrapper.shared.configure()
}

// MARK: - Version Information

/// Get current SDK version
public func artiusIDSDKVersion() -> String {
    return ArtiusIDSDKInfo.version
}

/// Print SDK information to console
public func printArtiusIDSDKInfo() {
    ArtiusIDSDKInfo.printInfo()
}
