// SDKResourceBundle.swift
// Resource bundle helper for accessing SDK assets in binary distribution
// Created by Curtis Elswick on 07/22/2025

import Foundation
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

/// Resource bundle helper for accessing SDK assets
public class SDKResourceBundle {
    public static let shared = SDKResourceBundle()
    
    private var _bundle: Bundle?
    public static let version = "1.0.98" 
    
    private init() {}
    
    public var bundle: Bundle {
        if let cached = _bundle {
            return cached
        }
        
        // Try to find the resource bundle in order of preference
        let candidates: [Bundle?] = [
            // 1. Look for ArtiusIDSDKResources.bundle in the framework
            Bundle(for: SDKResourceBundle.self).url(forResource: "ArtiusIDSDKResources", withExtension: "bundle").flatMap(Bundle.init),
            
            // 2. Look for the bundle in the main app bundle
            Bundle.main.url(forResource: "ArtiusIDSDKResources", withExtension: "bundle").flatMap(Bundle.init),
            
            // 3. Check if resources are in the framework bundle itself
            Bundle(for: SDKResourceBundle.self),
            
            // 4. Fallback to main bundle (if resources were copied to client app)
            Bundle.main
        ]
        
        for candidate in candidates.compactMap({ $0 }) {
            // Check if this bundle contains our specific resources
            if hasSDKResources(in: candidate) {
                _bundle = candidate
                print("[ArtiusIDSDK] Found resources in bundle: \(candidate.bundlePath)")
                return candidate
            }
        }
        
        // If no resources found, log warning but continue with main bundle
        print("[ArtiusIDSDK] Warning: Could not locate SDK resource bundle. Using main bundle as fallback.")
        _bundle = Bundle.main
        return Bundle.main
    }
    
    /// Check if a bundle contains SDK-specific resources
    private func hasSDKResources(in bundle: Bundle) -> Bool {
        // Check for localization files
        if bundle.url(forResource: "Localizable", withExtension: "strings", subdirectory: "en-US.lproj") != nil {
            return true
        }
        
        // Check for specific asset catalog
        if bundle.url(forResource: "Assets", withExtension: "car") != nil {
            return true
        }
        
        // Check for specific images that should be in the SDK
        if bundle.url(forResource: "logo", withExtension: "png") != nil ||
           bundle.url(forResource: "intro_home_view_image", withExtension: "png") != nil {
            return true
        }
        
        return false
    }
    
    /// Get localized string from the correct bundle
    public func localizedString(forKey key: String, value: String? = nil, table: String? = nil) -> String {
        let localizedValue = bundle.localizedString(forKey: key, value: value ?? key, table: table)
        
        // If we get back the key itself, the localization wasn't found
        if localizedValue == key && value == nil {
            print("[ArtiusIDSDK] Warning: Localized string not found for key: \(key)")
        }
        
        return localizedValue
    }
    
    /// Get localized string for a specific locale
    /// - Parameters:
    ///   - key: The localization key
    ///   - locale: The target locale
    ///   - fallback: Fallback string if not found
    /// - Returns: Localized string for the specified locale, or fallback/key
    public func localizedString(forKey key: String, locale: Locale, fallback: String? = nil) -> String {
        // Try to get the localized string from the specific locale's .lproj directory
        if let localizedValue = localizedStringFromLocaje(key, locale: locale, bundle: bundle) {
            return localizedValue
        }
        
        // Fallback to provided fallback or key
        return fallback ?? key
    }
    
    /// Get localized string from a specific locale's .lproj directory
    private func localizedStringFromLocaje(_ key: String, locale: Locale, bundle: Bundle) -> String? {
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        
        // Try language-region combination first (e.g., "es-ES", "en-US")
        if let regionCode = locale.region?.identifier {
            let localeIdentifier = "\(languageCode)-\(regionCode)"
            if let value = loadStringFromBundle(key, localization: localeIdentifier, bundle: bundle) {
                return value
            }
        }
        
        // Try just the language code (e.g., "es", "en")
        if let value = loadStringFromBundle(key, localization: languageCode, bundle: bundle) {
            return value
        }
        
        // Try lowercase language code as fallback
        if let value = loadStringFromBundle(key, localization: languageCode.lowercased(), bundle: bundle) {
            return value
        }
        
        return nil
    }
    
    /// Load localized string from a specific localization using Bundle's native support
    private func loadStringFromBundle(_ key: String, localization: String, bundle: Bundle) -> String? {
        // Try to get the localization bundle
        guard let lprojPath = bundle.path(forResource: localization, ofType: "lproj"),
              let lprojBundle = Bundle(path: lprojPath) else {
            return nil
        }
        
        // Load the string using the localization bundle
        let value = lprojBundle.localizedString(forKey: key, value: "__NOT_FOUND__", table: nil)
        
        // Return the value if it's not the not-found sentinel
        if value != "__NOT_FOUND__" && value != key {
            return value
        }
        
        return nil
    }
    
    /// Get localized string checking client bundle first, then SDK bundle
    /// This allows client apps to override SDK localizations
    public func localizedStringWithClientFallback(_ key: String, fallback: String? = nil, locale: Locale? = nil) -> String {
        // 1. First check if LocalizationManager has runtime overrides
        let locMgr = LocalizationManager.shared
        if locMgr.hasOverride(forKey: key) {
            return locMgr.string(forKey: key)
        }
        
        // Use provided locale or fall back to Locale.current
        let targetLocale = locale ?? Locale.current
        
        // 2. Check the main bundle (client's Localizable.strings) with target locale
        if let clientString = localizedStringFromLocaje(key, locale: targetLocale, bundle: .main) {
            return clientString
        }
        
        // 3. Fallback to main bundle with system locale
        let mainBundleString = NSLocalizedString(key, bundle: .main, value: "__NOT_FOUND__", comment: "")
        if mainBundleString != "__NOT_FOUND__" && mainBundleString != key {
            return mainBundleString
        }
        
        // 4. Check SDK resource bundle with target locale
        if let sdkString = localizedStringFromLocaje(key, locale: targetLocale, bundle: bundle) {
            return sdkString
        }
        
        // 5. Fallback to SDK resource bundle with system locale
        let sdkString = bundle.localizedString(forKey: key, value: "__NOT_FOUND__", table: nil)
        if sdkString != "__NOT_FOUND__" && sdkString != key {
            return sdkString
        }
        
        // 6. Use provided fallback or return key
        return fallback ?? key
    }
    
    /// Get image from the correct bundle
    public func image(named name: String) -> UIImage? {
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        
        if image == nil {
            print("[ArtiusIDSDK] Warning: Image not found: \(name)")
        }
        
        return image
    }
    
    /// Get URL for a resource file
    public func url(forResource name: String?, withExtension ext: String?, subdirectory: String? = nil) -> URL? {
        return bundle.url(forResource: name, withExtension: ext, subdirectory: subdirectory)
    }
    
    /// Get path for a resource file
    public func path(forResource name: String?, ofType ext: String?, inDirectory subpath: String? = nil) -> String? {
        return bundle.path(forResource: name, ofType: ext, inDirectory: subpath)
    }
}

/// SwiftUI Image extension for SDK resources
#if canImport(SwiftUI)
extension Image {
    /// Initialize Image from SDK resource bundle
    public static func sdkImage(named name: String) -> Image {
        if let uiImage = SDKResourceBundle.shared.image(named: name) {
            return Image(uiImage: uiImage)
        } else {
            // Return a fallback system image
            return Image(systemName: "photo")
        }
    }
}
#endif
