import Foundation

/// Centralized, type-safe access to app preferences stored in UserDefaults
///
/// By consolidating all persistence keys in one place, we prevent typos and maintain
/// a single source of truth for preference management. All keys are defined in the
/// PreferenceKey enum for compile-time safety.
///
/// Usage:
/// ```swift
/// AppPreferences.set("en", forKey: .appLanguage)
/// let language = AppPreferences.get(forKey: .appLanguage) ?? "en"
/// AppPreferences.remove(forKey: .appLanguage)
/// ```
struct AppPreferences {
    
    /// All app preference keys - centralized enum prevents typos and provides IDE autocomplete
    enum PreferenceKey: String {
        // Localization
        case appLanguage = "appLanguage"
        
        // Theme
        case appTheme = "appTheme"
        
        // Verification Flow
        case verificationAccountNumber = "verificationAccountNumber"
        case accountFullName = "accountFullName"
        
        // Authentication Flow
        case authenticationAccountNumber = "authenticationAccountNumber"
        
        // Environment Configuration
        case selectedEnvironment = "selectedEnvironment"
        case selectedDomain = "selectedDomain"
    }
    
    /// Set a preference value (stored as String in UserDefaults)
    /// - Parameters:
    ///   - value: The string value to store
    ///   - key: The preference key enum
    static func set(_ value: String?, forKey key: PreferenceKey) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    
    /// Get a preference value
    /// - Parameters:
    ///   - key: The preference key enum
    /// - Returns: The stored string value, or nil if not found
    static func get(forKey key: PreferenceKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    /// Remove a preference value
    /// - Parameters:
    ///   - key: The preference key enum
    static func remove(forKey key: PreferenceKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    /// Remove all stored preferences (typically used for logout/reset)
    static func removeAll(_ keys: [PreferenceKey]) {
        keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
}
