
// ArtiusIDSDKWrapper.swift
// Unified iOS bridge for ArtiusID SDK binary framework

import Foundation
import Security

#if canImport(artiusid_sdk_ios)
import artiusid_sdk_ios
#endif

// Provide backward compatibility with ArtiusIDSDK name
public typealias ArtiusIDSDK = ArtiusIDSDKWrapper

// MARK: - Public Type Exports from Binary SDK
#if canImport(artiusid_sdk_ios)
public typealias AppNotificationState = artiusid_sdk_ios.AppNotificationState
public typealias Environments = artiusid_sdk_ios.Environments
public typealias LogLevel = artiusid_sdk_ios.LogLevel
#endif

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
        logInfo("ArtiusID SDK dependencies initialized successfully", source: "ArtiusIDSDKWrapper")
    }

    /// Verify that all required dependencies are available
    public static func verifyDependencies() -> Bool {
        #if canImport(FirebaseCore)
        guard NSClassFromString("FIRApp") != nil else {
            logWarning("Firebase not available", source: "ArtiusIDSDKWrapper")
            return false
        }
        #endif
        #if canImport(FirebaseMessaging)
        guard NSClassFromString("FIRMessaging") != nil else {
            logWarning("Firebase Messaging not available", source: "ArtiusIDSDKWrapper")
            return false
        }
        #endif
        logInfo("All ArtiusID SDK dependencies verified", source: "ArtiusIDSDKWrapper")
        return true
    }
}

// Simple Keychain wrapper for FCM token storage and Okta ID
public class Keychain {
    private let service: String
    private let securityQueue = DispatchQueue(label: "com.artiusid.sdk.keychain.security")
    public init(service: String = "com.artiusid.sdk") { self.service = service }

    private func baseQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }

    public func set(_ value: String, forKey key: String) -> Bool {
        guard !key.isEmpty, let data = value.data(using: .utf8) else {
            return false
        }

        return securityQueue.sync {
            var addQuery = baseQuery(forKey: key)
            addQuery[kSecValueData as String] = data

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus == errSecSuccess {
                return true
            }
            guard addStatus == errSecDuplicateItem else {
                return false
            }

            let updateQuery = baseQuery(forKey: key)
            let attributesToUpdate: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            return updateStatus == errSecSuccess
        }
    }

    public func get(forKey key: String) -> String? {
        guard !key.isEmpty else {
            return nil
        }

        return securityQueue.sync {
            var query = baseQuery(forKey: key)
            query[kSecReturnData as String] = true
            query[kSecMatchLimit as String] = kSecMatchLimitOne

            var result: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            guard status == errSecSuccess, let data = result as? Data else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }
    }

    private func contains(_ key: String) -> Bool {
        var query = baseQuery(forKey: key)
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public func delete(forKey key: String) -> Bool {
        guard !key.isEmpty else {
            return true
        }

        return securityQueue.sync {
            // Skip delete when item does not exist to keep repeated calls idempotent.
            guard contains(key) else {
                return true
            }

            let query = baseQuery(forKey: key)
            let status = SecItemDelete(query as CFDictionary)
            return status == errSecSuccess || status == errSecItemNotFound
        }
    }

    // Helper for Okta ID (environment-specific)
    public func setOktaUserId(_ userId: String?, environment: String) {
        let normalizedEnvironment = environment.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEnvironment.isEmpty else {
            return
        }

        let key = "oktaUserId_\(normalizedEnvironment)"
        if let userId = userId, !userId.isEmpty {
            _ = set(userId, forKey: key)
        } else {
            _ = delete(forKey: key)
        }
    }

    public func getOktaUserId(environment: String) -> String? {
        let normalizedEnvironment = environment.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEnvironment.isEmpty else {
            return nil
        }

        let key = "oktaUserId_\(normalizedEnvironment)"
        return get(forKey: key)
    }
}

// MARK: - Main SDK Wrapper
public class ArtiusIDSDKWrapper {
    public static let shared = ArtiusIDSDKWrapper()
    private let keychain = Keychain()
    private var isFirebaseConfigured = false
    /// The Okta user ID explicitly set by the client app (preferred over keychain)
    private var oktaUserId: String?
    /// The current environment configuration
    private var environment: Environments?
    private init() {}

    // MARK: - Core SDK Interface

    /// Configure SDK with automatic dependency initialization
    /// - Parameters:
    ///   - environment: Target environment (.sandbox, .development, .staging, .production)
    ///   - urlTemplate: URL template for mobile services (e.g., "https://#env#.#domain#")
    ///   - mobileDomain: Domain for mobile services (e.g., "mobile.artiusid.dev")
    ///   - registrationUrlTemplate: URL template for registration services
    ///   - registrationDomain: Domain for registration services (e.g., "registration.artiusid.dev")
    ///   - clientId: Client ID for API requests
    ///   - clientGroupId: Client Group ID for API requests
    ///   - includeOktaIDInVerificationPayload: Whether to include Okta ID in verification requests (default: true)
    /// - Note: Client provides template + domain, SDK replaces tokens:
    ///   - #env# → environment prefix (sandbox, dev, stage, or empty)
    ///   - #domain# → provided domain string
    ///   Example for Sandbox:
    ///     urlTemplate: "https://#env#.#domain#"
    ///     mobileDomain: "mobile.artiusid.dev"
    ///     Result: "https://sandbox.mobile.artiusid.dev"
    ///   Example for Development:
    ///     urlTemplate: "https://#domain#"
    ///     mobileDomain: "service-mobile.dev.artiusid.dev"
    ///     Result: "https://service-mobile.dev.artiusid.dev"
    public func configure(
        environment: Environments? = nil,
        urlTemplate: String,
        mobileDomain: String,
        registrationUrlTemplate: String,
        registrationDomain: String,
        clientId: Int,
        clientGroupId: Int,
        logLevel: LogLevel = .info,
        includeOktaIDInVerificationPayload: Bool = true,
        oktaUserId: String? = nil
    ) {
        // Initialize dependencies first
        ArtiusIDSDKDependencies.initialize()
        guard ArtiusIDSDKDependencies.verifyDependencies() else {
            fatalError("ArtiusID SDK dependencies not properly configured")
        }

        // Persist Okta ID only when explicitly provided to avoid clearing on repeated configure calls.
        if let providedOktaUserId = oktaUserId {
            self.oktaUserId = providedOktaUserId.isEmpty ? nil : providedOktaUserId

            if let env = environment?.rawValue, !env.isEmpty {
                keychain.setOktaUserId(self.oktaUserId, environment: env)
                if let userId = self.oktaUserId {
                    logInfo("Okta user ID set and stored in keychain: \(userId.prefix(10))...", source: "ArtiusIDSDKWrapper")
                } else {
                    logInfo("Okta user ID cleared from keychain", source: "ArtiusIDSDKWrapper")
                }
            } else {
                logWarning("Skipping Okta user ID keychain update because environment is missing", source: "ArtiusIDSDKWrapper")
            }
        } else {
            logDebug("No Okta user ID provided during configure; preserving existing keychain value", source: "ArtiusIDSDKWrapper")
        }

        // Set wrapper-level logging
        do {
            try setLoggingLevel(logLevel)
        } catch {
            logError("Failed to set logging level: \(error)", source: "ArtiusIDSDKWrapper")
        }

        configureFirebaseIfAvailable()
        self.environment = environment
        logDebug("Configuration:", source: "ArtiusIDSDKWrapper")
        logDebug("  Environment: \(String(describing: environment))", source: "ArtiusIDSDKWrapper")
        logDebug("  URL Template: \(urlTemplate)", source: "ArtiusIDSDKWrapper")
        logDebug("  Mobile Domain: \(mobileDomain)", source: "ArtiusIDSDKWrapper")
        logDebug("  Registration Template: \(registrationUrlTemplate)", source: "ArtiusIDSDKWrapper")
        logDebug("  Registration Domain: \(registrationDomain)", source: "ArtiusIDSDKWrapper")
        logDebug("  Client ID: \(clientId)", source: "ArtiusIDSDKWrapper")
        logDebug("  Client Group ID: \(clientGroupId)", source: "ArtiusIDSDKWrapper")
        logDebug("  Log Level: \(logLevel)", source: "ArtiusIDSDKWrapper")
        logDebug("  Include Okta ID: \(includeOktaIDInVerificationPayload)", source: "ArtiusIDSDKWrapper")
        if let oktaUserId = oktaUserId {
            logDebug("  Okta User ID (explicit): \(String(oktaUserId.prefix(10)))...", source: "ArtiusIDSDKWrapper")
        }
        // Configure the binary SDK with all parameters
        if let env = environment {
            ArtiusIDSDK.shared.configure(
                environment: env,
                urlTemplate: urlTemplate,
                mobileDomain: mobileDomain,
                registrationUrlTemplate: registrationUrlTemplate,
                registrationDomain: registrationDomain,
                clientId: clientId,
                clientGroupId: clientGroupId,
                includeOktaIDInVerificationPayload: includeOktaIDInVerificationPayload
            )
        }
        logInfo("SDK initialized successfully", source: "ArtiusIDSDKWrapper")
    }

    /// Set or update the Okta user ID at runtime (preferred over keychain)
    public func setOktaUserId(_ userId: String?) {
        self.oktaUserId = userId
        let env = self.environment?.rawValue ?? ""
        keychain.setOktaUserId(userId, environment: env)
        logInfo("Okta user ID set explicitly: \(userId?.prefix(10) ?? "nil")...", source: "ArtiusIDSDKWrapper")
    }

    /// Get the Okta user ID to use for verification (explicit > keychain)
    public func getOktaUserId(for environment: String? = nil) -> String? {
        if let explicit = oktaUserId, !explicit.isEmpty {
            return explicit
        }
        // Fallback to keychain if not set
        let env = environment ?? self.environment?.rawValue ?? ""
        return keychain.getOktaUserId(environment: env)
    }

    /// Set logging level for the wrapper (binary SDK manages its own logging)
    private func setLoggingLevel(_ level: LogLevel) throws {
        // The wrapper applies logging at the wrapper level only
        // Binary SDK logging is configured internally
        switch level {
        case .debug:
            logInfo("Debug logging enabled", source: "ArtiusIDSDKWrapper")
        case .info:
            logInfo("Info logging enabled", source: "ArtiusIDSDKWrapper")
        case .warning:
            logInfo("Warning logging enabled", source: "ArtiusIDSDKWrapper")
        case .error:
            logInfo("Error logging enabled", source: "ArtiusIDSDKWrapper")
        @unknown default:
            logWarning("Unknown log level: \(level)", source: "ArtiusIDSDKWrapper")
        }
    }

    /// Configure Firebase if available
    private func configureFirebaseIfAvailable() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() != nil {
            isFirebaseConfigured = true
            setupFCMTokenHandling()
            logInfo("Firebase integration enabled", source: "ArtiusIDSDKWrapper")
        } else {
            logWarning("Firebase available but not configured by client app", source: "ArtiusIDSDKWrapper")
        }
        #else
        logWarning("Firebase not available - operating in standalone mode", source: "ArtiusIDSDKWrapper")
        #endif
        // Certificate logic is now handled internally by the binary SDK
    }

    /// Update FCM token securely in keychain
    public func updateFCMToken(_ token: String) {
        _ = keychain.set(token, forKey: "fcmToken")
        ArtiusIDSDK.shared.updateFCMToken(token)
        logInfo("FCM token updated securely and passed to SDK", source: "ArtiusIDSDKWrapper")
    }

    /// Get current FCM token from secure storage
    public func getCurrentFCMToken() -> String? {
        return keychain.get(forKey: "fcmToken")
    }

    // MARK: - Language Management

    /// Set the SDK's display language at runtime
    /// - Parameter languageCode: Language code (e.g., "en", "es", "fr")
    public func setLanguage(_ languageCode: String) {
        artiusid_sdk_ios.LocalizationManager.shared.setLocale(Locale(identifier: languageCode))
        logInfo("Language set to \(languageCode)", source: "ArtiusIDSDKWrapper")
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

    /// Get the SDK version string
    /// - Returns: SDK version (e.g., "2.0.59")
    public func getSDKVersion() -> String {
        return ArtiusIDSDKInfo.version
    }

    /// Check if SDK is ready for verification (FCM token available)
    public func isReadyForVerification() -> Bool {
        return getCurrentFCMToken() != nil
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
    public static let version = "2.0.144"
    public static let wrapperVersion = "2.0.144"
    public static let build = "iOS Universal Binary (Device + Simulator)"
    public static let architecture = "iOS (arm64 + x86_64)"
    public static func printInfo() {
        logInfo("ArtiusID SDK v\(version) (\(build)) - \(architecture)", source: "ArtiusIDSDKInfo")
        logInfo("Wrapper: iPhone and iPad optimized with Firebase integration", source: "ArtiusIDSDKInfo")
        logInfo("Production size: ~30MB (device slice only)", source: "ArtiusIDSDKInfo")
    }
}

// MARK: - ArtiusID Namespace
/// Convenience namespace for accessing SDK components
public enum ArtiusID {
    #if canImport(artiusid_sdk_ios)
    public static var AppNotificationState: artiusid_sdk_ios.AppNotificationState.Type {
        return artiusid_sdk_ios.AppNotificationState.self
    }
    #endif
}

// MARK: - Public Convenience API
/// Public convenience API for configuring the SDK
/// - oktaUserId: (Optional) Pass the Okta user ID directly from the client app for maximum reliability
public func configureArtiusIDSDK(
    environment: Environments? = nil,
    urlTemplate: String,
    mobileDomain: String,
    registrationUrlTemplate: String,
    registrationDomain: String,
    clientId: Int,
    clientGroupId: Int,
    logLevel: LogLevel = .info,
    includeOktaIDInVerificationPayload: Bool = true,
    oktaUserId: String? = nil
) {
    ArtiusIDSDKWrapper.shared.configure(
        environment: environment,
        urlTemplate: urlTemplate,
        mobileDomain: mobileDomain,
        registrationUrlTemplate: registrationUrlTemplate,
        registrationDomain: registrationDomain,
        clientId: clientId,
        clientGroupId: clientGroupId,
        logLevel: logLevel,
        includeOktaIDInVerificationPayload: includeOktaIDInVerificationPayload,
        oktaUserId: oktaUserId
    )
}

public func artiusIDSDKVersion() -> String {
    return ArtiusIDSDKInfo.version
}

public func printArtiusIDSDKInfo() {
    ArtiusIDSDKInfo.printInfo()
}
