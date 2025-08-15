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
    public static let version = "1.0.97" 
    
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

/// String extension for SDK localization
extension String {
    /// Get localized string from SDK bundle
    public static func sdkLocalized(_ key: String) -> String {
        return SDKResourceBundle.shared.localizedString(forKey: key)
    }
}
