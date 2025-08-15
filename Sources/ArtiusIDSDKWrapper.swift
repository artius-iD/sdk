// ArtiusIDSDKWrapper.swift
// Unified iOS bridge for ArtiusID SDK binary framework

import Foundation
import Security

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

// Re-export all public types from the binary framework
#if canImport(artiusid_sdk_ios)
@_exported import artiusid_sdk_ios
#endif

// Provide backward compatibility with ArtiusIDSDK name
public typealias ArtiusIDSDK = ArtiusIDSDKWrapper

// MARK: - Dependency Initialization & Verification
public final class ArtiusIDSDKDependencies {
    /// Initialize dependencies to ensure proper linking
    /// Call this before using any SDK functionality
    public static func initialize() {
        #if canImport(FirebaseCore)
        _ = FirebaseApp.self
        #endif
        #if canImport(FirebaseMessaging)
        _ = Messaging.self
        #endif
        logDebug("ArtiusID SDK dependencies initialized successfully", source: "ArtiusIDSDKWrapper")
    }

    /// Verify that all required dependencies are available
    public static func verifyDependencies() -> Bool {
        #if canImport(FirebaseCore)
        guard NSClassFromString("FIRApp") != nil else {
            logDebug("❌ Firebase not available", source: "ArtiusIDSDKWrapper")
            return false
        }
        #endif
        #if canImport(FirebaseMessaging)
        guard NSClassFromString("FIRMessaging") != nil else {
            logDebug("❌ Firebase Messaging not available", source: "ArtiusIDSDKWrapper")
            return false
        }
        #endif
        logDebug("✅ All ArtiusID SDK dependencies verified", source: "ArtiusIDSDKWrapper")
        return true
    }
}

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

// MARK: - Main SDK Wrapper
public class ArtiusIDSDKWrapper {
    public static let shared = ArtiusIDSDKWrapper()
    private let keychain = Keychain()
    private var isFirebaseConfigured = false
    private init() {}

    // MARK: - Core SDK Interface

    /// Configure SDK with automatic dependency initialization
    public func configure(environment: Environments? = nil, logLevel: LogLevel = .info) {
        // Initialize dependencies first
        ArtiusIDSDKDependencies.initialize()
        guard ArtiusIDSDKDependencies.verifyDependencies() else {
            fatalError("ArtiusID SDK dependencies not properly configured")
        }
        configureFirebaseIfAvailable()
        logDebug("[ArtiusIDSDKWrapper] configure called with environment: \(String(describing: environment)), logLevel: \(logLevel)", source: "ArtiusIDSDKWrapper")
        // If environment is provided, configure the binary SDK
        if let env = environment {
            logDebug("[ArtiusIDSDKWrapper] Calling ArtiusIDSDK.shared.configure with environment: \(env)", source: "ArtiusIDSDKWrapper")
            ArtiusIDSDK.shared.configure(environment: env)
        }
        logDebug("[ArtiusIDSDKWrapper] initialized for iPhone and iPad", source: "ArtiusIDSDKWrapper")
    }

    /// Update FCM token securely in keychain
    public func updateFCMToken(_ token: String) {
    _ = keychain.set(token, forKey: "fcm_token")
    ArtiusIDSDK.shared.updateFCMToken(token)
    logDebug("[ArtiusIDSDKWrapper] FCM token updated securely and passed to SDK", source: "ArtiusIDSDKWrapper")
    }

    /// Get current FCM token from secure storage
    public func getCurrentFCMToken() -> String? {
        return keychain.get(forKey: "fcm_token")
    }

    /// Get comprehensive SDK and integration information
    public func getSDKInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        info["sdkVersion"] = ArtiusIDSDKInfo.version
        info["wrapperVersion"] = ArtiusIDSDKInfo.wrapperVersion
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
        return info
    }

    /// Check if SDK is ready for verification (FCM token available)
    public func isReadyForVerification() -> Bool {
        return getCurrentFCMToken() != nil
    }

    // MARK: - Private Implementation

    /// Configure Firebase integration if available
    private func configureFirebaseIfAvailable() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() != nil {
            isFirebaseConfigured = true
            setupFCMTokenHandling()
            logDebug("[ArtiusIDSDKWrapper] Firebase integration enabled", source: "ArtiusIDSDKWrapper")
        } else {
            logDebug("[ArtiusIDSDKWrapper] Firebase available but not configured by client app", source: "ArtiusIDSDKWrapper")
        }
        #else
        logDebug("[ArtiusIDSDKWrapper] Firebase not available - operating in standalone mode", source: "ArtiusIDSDKWrapper")
        #endif
        // Certificate logic is now handled internally by the binary SDK
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
}

// SDK Information and utilities
public struct ArtiusIDSDKInfo {
    public static let version = "1.0.98"
    public static let wrapperVersion = "1.0.21"
    public static let build = "iOS Universal Binary (Device + Simulator)"
    public static let architecture = "iOS (arm64 + x86_64)"
    public static func printInfo() {
        logDebug("ArtiusID SDK v\(version) (\(build)) - \(architecture)", source: "ArtiusIDSDKWrapper")
        logDebug("Wrapper: iPhone and iPad optimized with Firebase integration", source: "ArtiusIDSDKWrapper")
        logDebug("Production size: ~30MB (device slice only)", source: "ArtiusIDSDKWrapper")
    }
}

// MARK: - Public Convenience API
public typealias ArtiusID = ArtiusIDSDKWrapper

public func configureArtiusIDSDK(environment: Environments? = nil, logLevel: LogLevel = .info) {
    ArtiusIDSDKWrapper.shared.configure(environment: environment, logLevel: logLevel)
}

public func artiusIDSDKVersion() -> String {
    return ArtiusIDSDKInfo.version
}

public func printArtiusIDSDKInfo() {
    ArtiusIDSDKInfo.printInfo()
}
