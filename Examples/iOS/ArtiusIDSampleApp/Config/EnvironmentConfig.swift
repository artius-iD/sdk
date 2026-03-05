//
//  EnvironmentConfig.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 10/29/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import Foundation
import artiusid_sdk_ios

/// Environment configuration for the sample app
///
/// Manages endpoint URLs, domains, and credentials for different SDK environments.
/// Use `EnvironmentManager.shared.setEnvironment()` and `SampleAppViewModel.updateEnvironment()`
/// to switch environments at runtime.
///
/// **For SDK Users:**
/// 1. Define your own environments (or use these pre-configured ones)
/// 2. Store environment-specific client IDs, domains, and endpoints
/// 3. Update SDK configuration before launching flows via `ArtiusIDSDK.shared.setSDKConfiguration()`
///
public struct EnvironmentConfig {
    
    // MARK: - Environment Types
    
    /// Available SDK environments for testing and production
    ///
    /// Each environment has different endpoints, domains, and certificate requirements.
    /// Switch environments in settings; certificate re-registration is automatic.
    public enum Environment: String, CaseIterable, Identifiable {
        case sandbox
        case development
        case staging
        
        public var id: String { rawValue }
        
        public var displayName: String {
            switch self {
            case .sandbox: return "Sandbox"
            case .development: return "Development"
            case .staging: return "Staging"
            }
        }
        
        public var description: String {
            switch self {
            case .sandbox:
                return "Sandbox testing environment"
            case .development:
                return "Development environment"
            case .staging:
                return "Staging/pre-production environment"
            }
        }
        
        /// URL template for mobile services
        /// Contains #env# and #domain# tokens that SDK will replace
        public var mobileURLTemplate: String {
            switch self {
            case .sandbox:
                // NEW pattern: #env# will be prepended to #domain#
                return "https://#env#.#domain#"
                
            case .development, .staging:
                // OLD pattern: #env# already embedded in domain
                return "https://#domain#"
            }
        }
        
        /// URL template for registration services
        public var registrationURLTemplate: String {
            switch self {
            case .sandbox:
                // NEW pattern: #env# will be prepended to #domain#
                return "https://#env#.#domain#"
                
            case .development, .staging:
                // OLD pattern: #env# already embedded in domain
                return "https://#domain#"
            }
        }
        
        /// Mobile domain (service type + base domain)
        /// SDK will replace #domain# token with this value
        public var mobileDomain: String {
            switch self {
            case .sandbox:
                return "mobile.artiusid.dev"
                
            case .development:
                return "service-mobile.dev.artiusid.dev"
                
            case .staging:
                return "service-mobile.stage.artiusid.dev"
            }
        }
        
        /// Registration domain (service type + base domain)
        /// SDK will replace #domain# token with this value
        public var registrationDomain: String {
            switch self {
            case .sandbox:
                return "registration.artiusid.dev"
                
            case .development:
                return "service-registration.dev.artiusid.dev"
                
            case .staging:
                return "service-registration.stage.artiusid.dev"
            }
        }
        
        /// Computed mobile base URL (for display/logging only)
        public var baseURL: String {
            let envToken = environmentToken
            return mobileURLTemplate
                .replacingOccurrences(of: "#env#", with: envToken)
                .replacingOccurrences(of: "#domain#", with: mobileDomain)
        }
        
        /// Computed registration URL (for display/logging only)
        public var registrationURL: String {
            let envToken = environmentToken
            return registrationURLTemplate
                .replacingOccurrences(of: "#env#", with: envToken)
                .replacingOccurrences(of: "#domain#", with: registrationDomain)
        }
        
        /// Environment token for URL processing
        private var environmentToken: String {
            switch self {
            case .sandbox: return "sandbox"
            case .development: return "dev"
            case .staging: return "stage"
            }
        }
        
        public var certificateURL: String {
            return "\(registrationURL)/LoadCertificateFunction"
        }
        
        /// Visual indicator emoji for UI display
        public var icon: String {
            switch self {
            case .sandbox: return "🏖️"
            case .development: return "🔧"
            case .staging: return "🧪"
            }
        }
        
        /// Color for highlighting environment selection in UI
        public var color: String {
            switch self {
            case .sandbox: return "#4CAF50"      // Green
            case .development: return "#2196F3"  // Blue
            case .staging: return "#FF9800"      // Orange
            }
        }
    }
    
    // MARK: - Configuration
    
    let environment: Environment
    let apiKey: String
    let clientId: Int
    let clientGroupId: Int
    let enableLogging: Bool
    
    // MARK: - Initializer
    
    public init(
        environment: Environment,
        apiKey: String,
        clientId: Int,
        clientGroupId: Int,
        enableLogging: Bool = true
    ) {
        self.environment = environment
        self.apiKey = apiKey
        self.clientId = clientId
        self.clientGroupId = clientGroupId
        self.enableLogging = enableLogging
    }
    
    // MARK: - SDK Configuration
    
    /// Convert to SDK configuration  
    /// This creates the configuration object AND configures the internal SDK with template + domains
    public func toSDKConfiguration(
        localizationOverrides: [String: String] = [:],
        imageOverrides: SDKImageOverrides? = nil,
        includeOktaIDInVerificationPayload: Bool = false
    ) -> SDKConfiguration {
        // Configure the internal SDK with environment, template, domains, and client IDs
        ArtiusIDSDK.shared.configure(
            environment: toSDKEnvironment(),
            urlTemplate: environment.mobileURLTemplate,
            mobileDomain: environment.mobileDomain,
            registrationUrlTemplate: environment.registrationURLTemplate,
            registrationDomain: environment.registrationDomain,
            clientId: clientId,
            clientGroupId: clientGroupId,
            includeOktaIDInVerificationPayload: includeOktaIDInVerificationPayload
        )
        
        return SDKConfiguration(
            apiKey: apiKey,
            environment: toSDKEnvironment(),
            clientId: clientId,
            clientGroupId: clientGroupId,
            enableLogging: enableLogging,
            handleFirebaseNotifications: false,  // Sample app handles Firebase
            localizationOverrides: localizationOverrides,
            imageOverrides: imageOverrides
        )
    }
    
    /// Convert to SDK environment
    private func toSDKEnvironment() -> Environments {
        switch environment {
        case .sandbox:
            return .sandbox  // ✅ Matches keychain key "fcm_token_sandbox"
        case .development:
            return .development  // ✅ Matches keychain key "fcm_token_development"
        case .staging:
            return .staging  // ✅ Matches keychain key "fcm_token_staging"
        }
    }
    
    // MARK: - Preset Configurations
    
    /// Sandbox configuration for testing
    public static let sandboxConfig = EnvironmentConfig(
        environment: .sandbox,
        apiKey: "sandbox_api_key_here",
        clientId: 1,
        clientGroupId: 1,
        enableLogging: true
    )
    
    /// Development configuration
    public static let developmentConfig = EnvironmentConfig(
        environment: .development,
        apiKey: "development_api_key_here",
        clientId: 1,
        clientGroupId: 1,
        enableLogging: true
    )
    
    /// Staging configuration
    public static let stagingConfig = EnvironmentConfig(
        environment: .staging,
        apiKey: "staging_api_key_here",
        clientId: 1,
        clientGroupId: 1,
        enableLogging: true
    )
    
    /// Get configuration for a specific environment
    ///
    /// Returns pre-configured URLs, domains, and client credentials for the environment.
    /// Use this to set up SDK configuration before launching flows.
    public static func configForEnvironment(_ environment: Environment) -> EnvironmentConfig {
        switch environment {
        case .sandbox: return sandboxConfig
        case .development: return developmentConfig
        case .staging: return stagingConfig
        }
    }
}

// MARK: - App Configuration

/// Complete app configuration combining all settings
public struct AppConfiguration {
    let environmentConfig: EnvironmentConfig
    let theme: ThemeOption
    let imageOverrideScenario: ImageOverrideOption
    let localizationStyle: LocalizationStyle
    let language: Language
    let isOktaIdEnabled: Bool
    
    public init(
        environment: EnvironmentConfig.Environment = .sandbox,
        theme: ThemeOption = .artiusDefault,
        imageOverrideScenario: ImageOverrideOption = .default,
        localizationStyle: LocalizationStyle = .standard,
        language: Language = .english,
        isOktaIdEnabled: Bool = false
    ) {
        self.environmentConfig = EnvironmentConfig.configForEnvironment(environment)
        self.theme = theme
        self.imageOverrideScenario = imageOverrideScenario
        self.localizationStyle = localizationStyle
        self.language = language
        self.isOktaIdEnabled = isOktaIdEnabled
    }
    
    /// Create complete SDK configuration
    public func createSDKConfiguration() -> (
        theme: EnhancedSDKThemeConfiguration,
        config: SDKConfiguration
    ) {
        let themeConfig = theme.themeConfig
        let imageOverrides = imageOverrideScenario.overrides
        let localizations = localizationStyle.localizations
        
        let sdkConfig = environmentConfig.toSDKConfiguration(
            localizationOverrides: localizations,
            imageOverrides: imageOverrides,
            includeOktaIDInVerificationPayload: isOktaIdEnabled
        )
        
        return (themeConfig, sdkConfig)
    }
}

