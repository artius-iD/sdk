// ArtiusIDSDKWrapper.swift
// iOS-only wrapper for ArtiusID SDK binary framework
// Optimized for iPhone and iPad devices
// Created by Curtis Elswick on 07/07/2025

import Foundation
import UIKit           // Direct import - iPhone and iPad only
import Security        // For keychain operations

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

#if canImport(OpenSSL)
import OpenSSL
#endif

@_exported import artiusid_sdk_ios

// Simple Keychain wrapper for FCM token storage
private class Keychain {
    private let service: String
    init(service: String = "com.artiusid.sdk") { self.service = service }
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

// Enhanced ArtiusID SDK Wrapper for iPhone and iPad
public class ArtiusIDSDKWrapper {
    public static let shared = ArtiusIDSDKWrapper()
    private let keychain = Keychain()
    private var isFirebaseConfigured = false
    private init() {}

    // MARK: - Core SDK Interface

    /// Initialize the ArtiusID SDK with enhanced wrapper features
    public func configure() {
        configureFirebaseIfAvailable()
        ensureClientCertificate()
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

    /// Check if client certificate exists
    public func hasClientCertificate() -> Bool {
        // Replace with actual SDK certificate check
        return CertificateManager.shared.hasCertificate()
    }

    /// Get comprehensive SDK and integration information
    public func getSDKInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        info["sdkVersion"] = ArtiusIDSDKInfo.version
        info["wrapperVersion"] = "1.0.21"
        info["platform"] = "iPhone/iPad"
        info["architecture"] = ArtiusIDSDKInfo.architecture
        #if canImport(FirebaseCore)
        info["firebaseAvailable"] = true
        info["firebaseConfigured"] = isFirebaseConfigured
        #else
        info["firebaseAvailable"] = false
        info["firebaseConfigured"] = false
        #endif
        info["fcmTokenAvailable"] = getCurrentFCMToken() != nil
        info["clientCertificateAvailable"] = hasClientCertificate()
        return info
    }

    /// Check if SDK is ready for verification (both FCM token and certificate available)
    public func isReadyForVerification() -> Bool {
        return getCurrentFCMToken() != nil && hasClientCertificate()
    }

    // MARK: - Private Implementation

    /// Configure Firebase integration if available
    private func configureFirebaseIfAvailable() {
        #if canImport(FirebaseCore)
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
        Messaging.messaging().token { [weak self] token, error in
            if let token = token {
                self?.updateFCMToken(token)
            }
        }
        #endif
    }

    /// Ensure client certificate exists, generate if missing
    private func ensureClientCertificate() {
        // Replace with actual SDK certificate generation/check logic
        if !CertificateManager.shared.hasCertificate() {
            CertificateManager.shared.generateCertificate()
            print("[ArtiusIDSDKWrapper] Client certificate generated")
        } else {
            print("[ArtiusIDSDKWrapper] Client certificate already exists")
        }
    }
}

// SDK Information and utilities
public struct ArtiusIDSDKInfo {
    public static let version = "1.0.26"
    public static let build = "iOS Universal Binary (Device + Simulator)"
    public static let architecture = "iOS (arm64 + x86_64)"
    public static func printInfo() {
        print("ArtiusID SDK v\(version) (\(build)) - \(architecture)")
        print("Wrapper: iPhone and iPad optimized with Firebase integration")
        print("Production size: ~30MB (device slice only)")
    }
}

// MARK: - Public Convenience API

public typealias ArtiusID = ArtiusIDSDKWrapper

public func configureArtiusIDSDK() {
    ArtiusIDSDKWrapper.shared.configure()
}

public func artiusIDSDKVersion() -> String {
    return ArtiusIDSDKInfo.version
}

public func printArtiusIDSDKInfo() {
    ArtiusIDSDKInfo.printInfo()
}
