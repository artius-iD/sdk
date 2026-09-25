
// ArtiusIDSDKWrapper.swift
// Unified iOS bridge for ArtiusID SDK binary framework

import Foundation
import Security

#if canImport(SwiftUI)
import SwiftUI
#endif

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
public typealias ThirdPartyLoginResult = artiusid_sdk_ios.ArtiusIDSDK.ThirdPartyLoginResult
public typealias ThirdPartyLoginHandler = artiusid_sdk_ios.ArtiusIDSDK.ThirdPartyLoginHandler
// The result types live in the binary; the package no longer compiles its own copies.
public typealias VerificationResult = artiusid_sdk_ios.VerificationResult
public typealias BindingEnrollmentResult = artiusid_sdk_ios.BindingEnrollmentResult
#if canImport(SwiftUI)
public typealias ThirdPartyLoginView = artiusid_sdk_ios.ThirdPartyLoginView
#endif
#endif

private enum WrapperLogger {
    private static let queue = DispatchQueue(label: "com.artiusid.sdk.wrapper.logger")

    static func info(_ message: @autoclosure () -> String, source: String) {
        queue.sync {
            logInfo(message(), source: source)
        }
    }

    static func debug(_ message: @autoclosure () -> String, source: String) {
        queue.sync {
            logDebug(message(), source: source)
        }
    }

    static func warning(_ message: @autoclosure () -> String, source: String) {
        queue.sync {
            logWarning(message(), source: source)
        }
    }

    static func error(_ message: @autoclosure () -> String, source: String) {
        queue.sync {
            logError(message(), source: source)
        }
    }
}

// MARK: - Dependency Initialization & Verification
public final class ArtiusIDSDKDependencies {
    private static let syncQueue = DispatchQueue(label: "com.artiusid.sdk.wrapper.dependencies")
    private static var didInitialize = false
    private static var hasVerifiedDependencies = false
    private static var lastVerificationResult = true

    /// Initialize dependencies to ensure proper linking
    /// Call this before using any SDK functionality
    public static func initialize() {
        syncQueue.sync {
            guard !didInitialize else {
                return
            }

            #if canImport(FirebaseCore)
            _ = FirebaseApp.self
            #endif
            #if canImport(FirebaseMessaging)
            _ = Messaging.self
            #endif

            didInitialize = true
            WrapperLogger.info("ArtiusID SDK dependencies initialized successfully", source: "ArtiusIDSDKWrapper")
        }
    }

    /// Verify that all required dependencies are available
    public static func verifyDependencies() -> Bool {
        syncQueue.sync {
            if hasVerifiedDependencies {
                return lastVerificationResult
            }

            var isValid = true

            #if canImport(FirebaseCore)
            if NSClassFromString("FIRApp") == nil {
                WrapperLogger.warning("Firebase not available", source: "ArtiusIDSDKWrapper")
                isValid = false
            }
            #endif
            #if canImport(FirebaseMessaging)
            if NSClassFromString("FIRMessaging") == nil {
                WrapperLogger.warning("Firebase Messaging not available", source: "ArtiusIDSDKWrapper")
                isValid = false
            }
            #endif

            hasVerifiedDependencies = true
            lastVerificationResult = isValid

            if isValid {
                WrapperLogger.info("All ArtiusID SDK dependencies verified", source: "ArtiusIDSDKWrapper")
            }

            return isValid
        }
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

        let key = artiusid_sdk_ios.ArtiusID.Environment.oktaUserIdKey(fromEnvironmentName: normalizedEnvironment)
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

        let key = artiusid_sdk_ios.ArtiusID.Environment.oktaUserIdKey(fromEnvironmentName: normalizedEnvironment)
        return get(forKey: key)
    }

    public func setThirdPartyLoginId(_ loginId: String?, environment: String) {
        let normalizedEnvironment = environment.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEnvironment.isEmpty else {
            return
        }

        let key = artiusid_sdk_ios.ArtiusID.Environment.thirdPartyLoginIdKey(fromEnvironmentName: normalizedEnvironment)
        if let loginId = loginId, !loginId.isEmpty {
            _ = set(loginId, forKey: key)
        } else {
            _ = delete(forKey: key)
        }
    }

    public func getThirdPartyLoginId(environment: String) -> String? {
        let normalizedEnvironment = environment.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEnvironment.isEmpty else {
            return nil
        }

        let key = artiusid_sdk_ios.ArtiusID.Environment.thirdPartyLoginIdKey(fromEnvironmentName: normalizedEnvironment)
        return get(forKey: key)
    }
}

// MARK: - Main SDK Wrapper
public class ArtiusIDSDKWrapper {
    private struct ConfigurationSignature: Equatable {
        let environmentRawValue: String?
        let urlTemplate: String
        let mobileDomain: String
        let registrationUrlTemplate: String
        let registrationDomain: String
        let clientId: Int
        let clientGroupId: Int
        let logLevel: String
        let includeOktaIDInVerificationPayload: Bool
        let verificationOperationMode: artiusid_sdk_ios.ArtiusID.OperationMode
        let isThirdPartyLoginEnabled: Bool
        let effectiveOktaUserId: String?
        let effectiveThirdPartyLoginId: String?
        let thirdPartyAuthToken: String?
        let thirdPartyLoginURL: String?
        let thirdPartyRegistrationURL: String?
    }

    public static let shared = ArtiusIDSDKWrapper()
    private let keychain = Keychain()
    private let stateQueue = DispatchQueue(label: "com.artiusid.sdk.wrapper.state")
    private var isFirebaseConfigured = false
    private var hasRegisteredFCMObservers = false
    /// The Okta user ID explicitly set by the client app (preferred over keychain)
    private var oktaUserId: String?
    /// The third-party login ID explicitly set by the client app (preferred over keychain)
    private var thirdPartyLoginId: String?
    /// The current environment configuration
    private var environment: Environments?
    private var thirdPartyAuthToken: String?
    private var thirdPartyLoginURL: String?
    private var thirdPartyRegistrationURL: String?
    private var lastConfigurationSignature: ConfigurationSignature?
    private init() {}

    // MARK: - Core SDK Interface

    /// Configure SDK with automatic dependency initialization
    /// - Parameters:
    ///   - environment: Target environment (.sandbox, .development, .staging, .production)
    ///   - urlTemplate: URL template for mobile services (e.g., "https://#env#.#domain#")
    ///   - mobileDomain: Domain for mobile services (e.g., "mobile.artiusid.ai")
    ///   - registrationUrlTemplate: URL template for registration services
    ///   - registrationDomain: Domain for registration services (e.g., "registration.artiusid.ai")
    ///   - clientId: Client ID for API requests
    ///   - clientGroupId: Client Group ID for API requests
    ///   - includeOktaIDInVerificationPayload: Whether to include Okta ID in verification requests (default: true)
    ///   - isThirdPartyLoginEnabled: Whether to enforce third-party login in the SDK flow (default: false)
    /// - Note: Client provides template + domain, SDK replaces tokens:
    ///   - #env# → environment prefix (sandbox, dev, stage, or empty)
    ///   - #domain# → provided domain string
    ///   Example for Sandbox:
    ///     urlTemplate: "https://#env#.#domain#"
    ///     mobileDomain: "mobile.artiusid.ai"
    ///     Result: "https://sandbox.mobile.artiusid.ai"
    ///   Example for Development:
    ///     urlTemplate: "https://#domain#"
    ///     mobileDomain: "service-mobile.dev.artiusid.ai"
    ///     Result: "https://service-mobile.dev.artiusid.ai"
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
        verificationOperationMode: artiusid_sdk_ios.ArtiusID.OperationMode = .bindingEnrollment,
        oktaUserId: String? = nil,
        // Defaults to true, matching ArtiusIDSDK.configure and Android.
        isThirdPartyLoginEnabled: Bool = true,
        thirdPartyLoginId: String? = nil,
        thirdPartyAuthToken: String? = nil,
        thirdPartyLoginURL: String? = nil,
        thirdPartyRegistrationURL: String? = nil
    ) {
        stateQueue.sync {
            // Initialize dependencies once and verify before first configure use.
            ArtiusIDSDKDependencies.initialize()
            guard ArtiusIDSDKDependencies.verifyDependencies() else {
                fatalError("ArtiusID SDK dependencies not properly configured")
            }

            let normalizedProvidedOktaUserId = oktaUserId?.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedProvidedThirdPartyLoginId = thirdPartyLoginId?.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedProvidedThirdPartyAuthToken = thirdPartyAuthToken?.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedProvidedThirdPartyLoginURL = thirdPartyLoginURL?.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedProvidedThirdPartyRegistrationURL = thirdPartyRegistrationURL?.trimmingCharacters(in: .whitespacesAndNewlines)

            // Persist Okta ID only when explicitly provided to avoid clearing on repeated configure calls.
            if let providedOktaUserId = normalizedProvidedOktaUserId {
                self.oktaUserId = providedOktaUserId.isEmpty ? nil : providedOktaUserId

                if let env = environment?.rawValue, !env.isEmpty {
                    keychain.setOktaUserId(self.oktaUserId, environment: env)
                    if let userId = self.oktaUserId {
                        WrapperLogger.info("Okta user ID set and stored in keychain: \(userId.prefix(10))...", source: "ArtiusIDSDKWrapper")
                    } else {
                        WrapperLogger.info("Okta user ID cleared from keychain", source: "ArtiusIDSDKWrapper")
                    }
                } else {
                    WrapperLogger.warning("Skipping Okta user ID keychain update because environment is missing", source: "ArtiusIDSDKWrapper")
                }
            } else {
                WrapperLogger.debug("No Okta user ID provided during configure; preserving existing keychain value", source: "ArtiusIDSDKWrapper")
            }

            if let providedThirdPartyLoginId = normalizedProvidedThirdPartyLoginId {
                self.thirdPartyLoginId = providedThirdPartyLoginId.isEmpty ? nil : providedThirdPartyLoginId

                if let env = environment?.rawValue, !env.isEmpty {
                    keychain.setThirdPartyLoginId(self.thirdPartyLoginId, environment: env)
                    if let loginId = self.thirdPartyLoginId {
                        WrapperLogger.info("Third-party login ID set and stored in keychain: \(loginId.prefix(10))...", source: "ArtiusIDSDKWrapper")
                    } else {
                        WrapperLogger.info("Third-party login ID cleared from keychain", source: "ArtiusIDSDKWrapper")
                    }
                } else {
                    WrapperLogger.warning("Skipping third-party login ID keychain update because environment is missing", source: "ArtiusIDSDKWrapper")
                }
            } else {
                WrapperLogger.debug("No third-party login ID provided during configure; preserving existing keychain value", source: "ArtiusIDSDKWrapper")
            }

            if let providedThirdPartyAuthToken = normalizedProvidedThirdPartyAuthToken {
                self.thirdPartyAuthToken = providedThirdPartyAuthToken.isEmpty ? nil : providedThirdPartyAuthToken
            }

            if let providedThirdPartyLoginURL = normalizedProvidedThirdPartyLoginURL {
                self.thirdPartyLoginURL = providedThirdPartyLoginURL.isEmpty ? nil : providedThirdPartyLoginURL
            }

            if let providedThirdPartyRegistrationURL = normalizedProvidedThirdPartyRegistrationURL {
                self.thirdPartyRegistrationURL = providedThirdPartyRegistrationURL.isEmpty ? nil : providedThirdPartyRegistrationURL
            }

            let effectiveSignature = ConfigurationSignature(
                environmentRawValue: environment?.rawValue,
                urlTemplate: urlTemplate,
                mobileDomain: mobileDomain,
                registrationUrlTemplate: registrationUrlTemplate,
                registrationDomain: registrationDomain,
                clientId: clientId,
                clientGroupId: clientGroupId,
                logLevel: String(describing: logLevel),
                includeOktaIDInVerificationPayload: includeOktaIDInVerificationPayload,
                verificationOperationMode: verificationOperationMode,
                isThirdPartyLoginEnabled: isThirdPartyLoginEnabled,
                effectiveOktaUserId: self.oktaUserId,
                effectiveThirdPartyLoginId: self.thirdPartyLoginId,
                thirdPartyAuthToken: self.thirdPartyAuthToken,
                thirdPartyLoginURL: self.thirdPartyLoginURL,
                thirdPartyRegistrationURL: self.thirdPartyRegistrationURL
            )

            // Idempotent: skip repeated configure for equivalent state.
            if lastConfigurationSignature == effectiveSignature {
                self.environment = environment
                WrapperLogger.debug("Skipping configure because effective configuration did not change", source: "ArtiusIDSDKWrapper")
                return
            }

            // Set wrapper-level logging
            do {
                try setLoggingLevel(logLevel)
            } catch {
                WrapperLogger.error("Failed to set logging level: \(error)", source: "ArtiusIDSDKWrapper")
            }

            configureFirebaseIfAvailableLocked()
            self.environment = environment

            WrapperLogger.debug("Configuration:", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Environment: \(String(describing: environment))", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  URL Template: \(urlTemplate)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Mobile Domain: \(mobileDomain)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Registration Template: \(registrationUrlTemplate)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Registration Domain: \(registrationDomain)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Client ID: \(clientId)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Client Group ID: \(clientGroupId)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Log Level: \(logLevel)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Include Okta ID: \(includeOktaIDInVerificationPayload)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Verification operation mode: \(verificationOperationMode.displayName)", source: "ArtiusIDSDKWrapper")
            WrapperLogger.debug("  Third-party login enabled: \(isThirdPartyLoginEnabled)", source: "ArtiusIDSDKWrapper")
            if let providedOktaUserId = normalizedProvidedOktaUserId, !providedOktaUserId.isEmpty {
                WrapperLogger.debug("  Okta User ID (explicit): \(String(providedOktaUserId.prefix(10)))...", source: "ArtiusIDSDKWrapper")
            }
            if let providedThirdPartyLoginId = normalizedProvidedThirdPartyLoginId, !providedThirdPartyLoginId.isEmpty {
                WrapperLogger.debug("  Third-party Login ID (explicit): \(String(providedThirdPartyLoginId.prefix(10)))...", source: "ArtiusIDSDKWrapper")
            }
            if let providedThirdPartyAuthToken = normalizedProvidedThirdPartyAuthToken, !providedThirdPartyAuthToken.isEmpty {
                WrapperLogger.debug("  Third-party auth token configured", source: "ArtiusIDSDKWrapper")
            }
            if let providedThirdPartyLoginURL = normalizedProvidedThirdPartyLoginURL, !providedThirdPartyLoginURL.isEmpty {
                WrapperLogger.debug("  Third-party login URL override: \(providedThirdPartyLoginURL)", source: "ArtiusIDSDKWrapper")
            }
            if let providedThirdPartyRegistrationURL = normalizedProvidedThirdPartyRegistrationURL, !providedThirdPartyRegistrationURL.isEmpty {
                WrapperLogger.debug("  Third-party registration URL override: \(providedThirdPartyRegistrationURL)", source: "ArtiusIDSDKWrapper")
            }

            #if canImport(artiusid_sdk_ios)
            // Configure the binary SDK with all parameters.
            if let env = environment {
                artiusid_sdk_ios.ArtiusIDSDK.shared.configure(
                    environment: env,
                    urlTemplate: urlTemplate,
                    mobileDomain: mobileDomain,
                    registrationUrlTemplate: registrationUrlTemplate,
                    registrationDomain: registrationDomain,
                    clientId: clientId,
                    clientGroupId: clientGroupId,
                    includeOktaIDInVerificationPayload: includeOktaIDInVerificationPayload,
                    verificationOperationMode: verificationOperationMode,
                    isThirdPartyLoginEnabled: isThirdPartyLoginEnabled,
                    thirdPartyAuthToken: self.thirdPartyAuthToken,
                    thirdPartyLoginURL: self.thirdPartyLoginURL,
                    thirdPartyRegistrationURL: self.thirdPartyRegistrationURL
                )
            }
            #endif

            lastConfigurationSignature = effectiveSignature
            WrapperLogger.info("SDK initialized successfully", source: "ArtiusIDSDKWrapper")
        }
    }

    /// Set or update the Okta user ID at runtime (preferred over keychain)
    public func setOktaUserId(_ userId: String?) {
        stateQueue.sync {
            let normalizedUserId = userId?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.oktaUserId = (normalizedUserId?.isEmpty == true) ? nil : normalizedUserId
            let env = self.environment?.rawValue ?? ""
            keychain.setOktaUserId(self.oktaUserId, environment: env)
            lastConfigurationSignature = nil
            WrapperLogger.info("Okta user ID set explicitly: \(self.oktaUserId?.prefix(10) ?? "nil")...", source: "ArtiusIDSDKWrapper")
        }
    }

    /// Get the Okta user ID to use for verification (explicit > keychain)
    public func getOktaUserId(for environment: String? = nil) -> String? {
        stateQueue.sync {
            if let explicit = oktaUserId, !explicit.isEmpty {
                return explicit
            }
            // Fallback to keychain if not set
            let env = environment ?? self.environment?.rawValue ?? ""
            return keychain.getOktaUserId(environment: env)
        }
    }

    public func setThirdPartyLoginId(_ loginId: String?) {
        stateQueue.sync {
            let normalizedLoginId = loginId?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.thirdPartyLoginId = (normalizedLoginId?.isEmpty == true) ? nil : normalizedLoginId
            let env = self.environment?.rawValue ?? ""
            keychain.setThirdPartyLoginId(self.thirdPartyLoginId, environment: env)
            lastConfigurationSignature = nil
            WrapperLogger.info("Third-party login ID set explicitly: \(self.thirdPartyLoginId?.prefix(10) ?? "nil")...", source: "ArtiusIDSDKWrapper")
        }
    }

    public func getThirdPartyLoginId(for environment: String? = nil) -> String? {
        stateQueue.sync {
            if let explicit = thirdPartyLoginId, !explicit.isEmpty {
                return explicit
            }
            let env = environment ?? self.environment?.rawValue ?? ""
            return keychain.getThirdPartyLoginId(environment: env)
        }
    }

    public func clearThirdPartyLoginId(for environment: String? = nil) {
        stateQueue.sync {
            let env = environment ?? self.environment?.rawValue ?? ""
            self.thirdPartyLoginId = nil
            keychain.setThirdPartyLoginId(nil, environment: env)
            lastConfigurationSignature = nil
            WrapperLogger.info("Third-party login ID cleared", source: "ArtiusIDSDKWrapper")
        }
    }

    public func setThirdPartyAuthToken(_ token: String?) {
        stateQueue.sync {
            let normalizedToken = token?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.thirdPartyAuthToken = (normalizedToken?.isEmpty == true) ? nil : normalizedToken
            #if canImport(artiusid_sdk_ios)
            artiusid_sdk_ios.ArtiusIDSDK.shared.setThirdPartyAuthToken(self.thirdPartyAuthToken)
            #endif
            lastConfigurationSignature = nil
        }
    }

    public func setThirdPartyLoginURL(_ url: String?) {
        stateQueue.sync {
            let normalizedURL = url?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.thirdPartyLoginURL = (normalizedURL?.isEmpty == true) ? nil : normalizedURL
            #if canImport(artiusid_sdk_ios)
            artiusid_sdk_ios.ArtiusIDSDK.shared.setThirdPartyLoginURL(self.thirdPartyLoginURL)
            #endif
            lastConfigurationSignature = nil
        }
    }

    public func setThirdPartyRegistrationURL(_ url: String?) {
        stateQueue.sync {
            let normalizedURL = url?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.thirdPartyRegistrationURL = (normalizedURL?.isEmpty == true) ? nil : normalizedURL
            #if canImport(artiusid_sdk_ios)
            artiusid_sdk_ios.ArtiusIDSDK.shared.setThirdPartyRegistrationURL(self.thirdPartyRegistrationURL)
            #endif
            lastConfigurationSignature = nil
        }
    }

    public func setThirdPartyLoginHandler(_ handler: ThirdPartyLoginHandler?) {
        stateQueue.sync {
            #if canImport(artiusid_sdk_ios)
            artiusid_sdk_ios.ArtiusIDSDK.shared.setThirdPartyLoginHandler(handler)
            #endif
            WrapperLogger.info("Third-party login handler updated", source: "ArtiusIDSDKWrapper")
        }
    }

    public func processThirdPartyLogin(loginId: String, password: String) async -> ThirdPartyLoginResult {
        #if canImport(artiusid_sdk_ios)
        return await artiusid_sdk_ios.ArtiusIDSDK.shared.processThirdPartyLogin(
            loginId: loginId,
            password: password
        )
        #else
        return ThirdPartyLoginResult(
            isSuccessful: false,
            loginId: nil,
            errorMessage: "Binary SDK not available"
        )
        #endif
    }

    public func validateCredentialsAndRegisterFCM(
        loginId: String,
        password: String,
        accountNumber: String? = nil
    ) async throws -> artiusid_sdk_ios.ArtiusIDSDK.ThirdPartyLoginResult {
        #if canImport(artiusid_sdk_ios)
        return try await artiusid_sdk_ios.ArtiusIDSDK.shared.validateCredentialsAndRegisterFCM(
            loginId: loginId,
            password: password,
            accountNumber: accountNumber
        )
        #else
        throw NSError(domain: "ArtiusIDSDKWrapper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Binary SDK not available"])
        #endif
    }

    /// Set logging level for the wrapper (binary SDK manages its own logging)
    private func setLoggingLevel(_ level: LogLevel) throws {
        // The wrapper applies logging at the wrapper level only
        // Binary SDK logging is configured internally
        switch level {
        case .debug:
            WrapperLogger.info("Debug logging enabled", source: "ArtiusIDSDKWrapper")
        case .info:
            WrapperLogger.info("Info logging enabled", source: "ArtiusIDSDKWrapper")
        case .warning:
            WrapperLogger.info("Warning logging enabled", source: "ArtiusIDSDKWrapper")
        case .error:
            WrapperLogger.info("Error logging enabled", source: "ArtiusIDSDKWrapper")
        @unknown default:
            WrapperLogger.warning("Unknown log level: \(level)", source: "ArtiusIDSDKWrapper")
        }
    }

    /// Configure Firebase if available
    private func configureFirebaseIfAvailableLocked() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() != nil {
            if !isFirebaseConfigured {
                isFirebaseConfigured = true
                WrapperLogger.info("Firebase integration enabled", source: "ArtiusIDSDKWrapper")
            }
            if !hasRegisteredFCMObservers {
                hasRegisteredFCMObservers = true
                setupFCMTokenHandlingLocked()
            }
        } else {
            WrapperLogger.warning("Firebase available but not configured by client app", source: "ArtiusIDSDKWrapper")
        }
        #else
        WrapperLogger.warning("Firebase not available - operating in standalone mode", source: "ArtiusIDSDKWrapper")
        #endif
        // Certificate logic is now handled internally by the binary SDK
    }

    /// Update FCM token securely in keychain
    public func updateFCMToken(_ token: String) {
        stateQueue.sync {
            _ = keychain.set(token, forKey: "fcmToken")
            #if canImport(artiusid_sdk_ios)
            artiusid_sdk_ios.ArtiusIDSDK.shared.updateFCMToken(token)
            #endif
            WrapperLogger.info("FCM token updated securely and passed to SDK", source: "ArtiusIDSDKWrapper")
        }
    }

    /// Get current FCM token from secure storage
    public func getCurrentFCMToken() -> String? {
        stateQueue.sync {
            keychain.get(forKey: "fcmToken")
        }
    }

    // MARK: - Language Management

    /// Set the SDK's display language at runtime
    /// - Parameter languageCode: Language code (e.g., "en", "es", "fr")
    public func setLanguage(_ languageCode: String) {
        stateQueue.sync {
            #if canImport(artiusid_sdk_ios)
            artiusid_sdk_ios.LocalizationManager.shared.setLocale(Locale(identifier: languageCode))
            #endif
            WrapperLogger.info("Language set to \(languageCode)", source: "ArtiusIDSDKWrapper")
        }
    }

    /// Get comprehensive SDK and integration information
    public func getSDKInfo() -> [String: Any] {
        stateQueue.sync {
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
            info["fcmTokenAvailable"] = keychain.get(forKey: "fcmToken") != nil
            return info
        }
    }

    /// Get the SDK version string
    /// - Returns: SDK version (e.g., "2.0.59")
    public func getSDKVersion() -> String {
        return ArtiusIDSDKInfo.version
    }

    /// Check if SDK is ready for verification (FCM token available)
    public func isReadyForVerification() -> Bool {
        stateQueue.sync {
            keychain.get(forKey: "fcmToken") != nil
        }
    }

    /// Setup FCM token refresh handling
    private func setupFCMTokenHandlingLocked() {
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
    public static let version = "3.1.4"
    public static let wrapperVersion = "3.1.4"
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
    verificationOperationMode: artiusid_sdk_ios.ArtiusID.OperationMode = .bindingEnrollment,
    oktaUserId: String? = nil,
    // Defaults to true, matching ArtiusIDSDK.configure and Android.
    isThirdPartyLoginEnabled: Bool = true,
    thirdPartyLoginId: String? = nil,
    thirdPartyAuthToken: String? = nil,
    thirdPartyLoginURL: String? = nil,
    thirdPartyRegistrationURL: String? = nil
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
        verificationOperationMode: verificationOperationMode,
        oktaUserId: oktaUserId,
        isThirdPartyLoginEnabled: isThirdPartyLoginEnabled,
        thirdPartyLoginId: thirdPartyLoginId,
        thirdPartyAuthToken: thirdPartyAuthToken,
        thirdPartyLoginURL: thirdPartyLoginURL,
        thirdPartyRegistrationURL: thirdPartyRegistrationURL
    )
}

public func artiusIDSDKVersion() -> String {
    return ArtiusIDSDKInfo.version
}

public func printArtiusIDSDKInfo() {
    ArtiusIDSDKInfo.printInfo()
}
