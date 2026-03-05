//
//  EnvironmentManager.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 11/03/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import Foundation
import artiusid_sdk_ios

/// Manages environment and domain configuration for the sample app
/// Equivalent to Android's UrlBuilder for persistent storage
public class EnvironmentManager {
    
    // MARK: - Singleton
    
    public static let shared = EnvironmentManager()
    
    // MARK: - Keys
    
    private let environmentKey = "selectedEnvironment"
    private let domainKey = "selectedDomain"
    
    // MARK: - Initialization
    
    private init() {
        logInfo("EnvironmentManager initialized", source: "EnvironmentManager")
    }
    
    // MARK: - Environment Management
    
    /// Get the currently selected environment
    /// - Returns: Environment name (e.g., "Sandbox", "Development", "Staging")
    public func getCurrentEnvironment() -> String {
        let environment = UserDefaults.standard.string(forKey: environmentKey) ?? "Sandbox"
        logDebug("Current environment: \(environment)", source: "EnvironmentManager")
        return environment
    }
    
    /// Set the current environment
    /// - Parameter environment: Environment name to set
    public func setEnvironment(_ environment: String) {
        logInfo("Setting environment to: \(environment)", source: "EnvironmentManager")
        UserDefaults.standard.set(environment, forKey: environmentKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Get the currently selected domain
    /// - Returns: Domain string (e.g., "artiusid.dev")
    public func getCurrentDomain() -> String {
        let domain = UserDefaults.standard.string(forKey: domainKey) ?? "artiusid.dev"
        logDebug("Current domain: \(domain)", source: "EnvironmentManager")
        return domain
    }
    
    /// Set the current domain
    /// - Parameter domain: Domain string to set
    public func setDomain(_ domain: String) {
        logInfo("Setting domain to: \(domain)", source: "EnvironmentManager")
        UserDefaults.standard.set(domain, forKey: domainKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Get the base URL for the current environment (matches Android UrlBuilder)
    /// - Returns: Base URL string for mobile API
    public func getBaseURL() -> String {
        let environment = getCurrentEnvironment()
        let domain = getCurrentDomain()
        
        switch environment.lowercased() {
        case "sandbox":
            return "https://sandbox.mobile.\(domain)"
        case "development", "dev":
            return "https://service-mobile.dev.\(domain)"
        case "staging", "stage":
            return "https://service-mobile.stage.\(domain)"
        default:
            return "https://service-mobile.stage.\(domain)"  // Default to staging
        }
    }
    
    /// Get the registration URL for the current environment (for certificate loading)
    /// - Returns: Base URL string for registration API
    public func getRegistrationURL() -> String {
        let environment = getCurrentEnvironment()
        let domain = getCurrentDomain()
        
        switch environment.lowercased() {
        case "sandbox":
            return "https://sandbox.registration.\(domain)"
        case "development", "dev":
            return "https://service-registration.dev.\(domain)"
        case "staging", "stage":
            return "https://service-registration.stage.\(domain)"
        default:
            return "https://service-registration.stage.\(domain)"  // Default to staging
        }
    }
    
    /// Get a summary of current configuration
    /// - Returns: Configuration summary string
    public func getConfigurationSummary() -> String {
        return "Environment: \(getCurrentEnvironment()), Domain: \(getCurrentDomain()), Base URL: \(getBaseURL())"
    }
    
    /// Reset to default configuration
    public func reset() {
        logInfo("Resetting to default configuration", source: "EnvironmentManager")
        UserDefaults.standard.removeObject(forKey: environmentKey)
        UserDefaults.standard.removeObject(forKey: domainKey)
        UserDefaults.standard.synchronize()
    }
}

