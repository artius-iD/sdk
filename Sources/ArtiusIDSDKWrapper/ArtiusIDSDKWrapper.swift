
// ArtiusIDSDKWrapper.swift
// iOS-only wrapper for ArtiusID SDK binary framework
// Optimized for iPhone and iPad devices
// Created by Curtis Elswick on 07/07/2025
//
// This wrapper exposes only the public certificate management API to client apps via protocol-based access.
// Use ArtiusIDSDKWrapper.shared.hasClientCertificate(), generateClientCertificate(), and removeClientCertificate() for certificate lifecycle.

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



#if canImport(CertificateManager)
import CertificateManager
#endif


// MARK: - CertificateManager Public API Protocol
/// Protocol exposing only the public certificate management functions to client apps.
public protocol CertificateManaging {
    /// Returns true if a client certificate exists in secure storage.
    func hasCertificate() -> Bool
    /// Generates and stores a new client certificate if missing.
    func generateCertificate()
    /// Removes the client certificate from secure storage.
    func removeCertificate() throws
}

/// Internal wrapper for CertificateManager, implementing only the public API.
class CertificateManagerWrapper: CertificateManaging {
    func hasCertificate() -> Bool {
        return CertificateManager.shared.hasCertificate()
    }
    func generateCertificate() {
        CertificateManager.shared.generateCertificate()
    }
    func removeCertificate() throws {
        try CertificateManager.shared.removeCertificate()
    }
}

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

/// Main entry point for ArtiusID SDK integration in client apps.
///
/// - Certificate management: Only public API exposed via protocol.
/// - Firebase integration: Automatic if available in client app.
/// - Keychain-based FCM token storage.
public class ArtiusIDSDKWrapper {
    public static let shared = ArtiusIDSDKWrapper()
    private let keychain = Keychain()
    private var isFirebaseConfigured = false
    private let certificateManager: CertificateManaging = CertificateManagerWrapper()
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

    /// Returns true if a client certificate exists in secure storage.
    public func hasClientCertificate() -> Bool {
        return certificateManager.hasCertificate()
    }

    /// Generates and stores a new client certificate if missing.
    public func generateClientCertificate() {
        certificateManager.generateCertificate()
    }

    /// Removes the client certificate from secure storage.
    public func removeClientCertificate() throws {
        try certificateManager.removeCertificate()
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
        if !hasClientCertificate() {
            generateClientCertificate()
            print("[ArtiusIDSDKWrapper] Client certificate generated")
        } else {
            print("[ArtiusIDSDKWrapper] Client certificate already exists")
        }
    }
}

// SDK Information and utilities
public struct ArtiusIDSDKInfo {
    public static let version = "1.0.28"
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
