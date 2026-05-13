//
//  SampleAppThemes.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 10/29/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import artiusid_sdk_ios

/// Sample theme configurations. artius.iD default uses SDK/reference-app colors (dark blue, orange).
public struct SampleAppThemes {
    
    // MARK: - artius.iD Default Theme
    
    /// artius.iD Default Theme – matches SDK and reference app (dark blue #22354D, orange #F58220).
    public static var ARTIUSID_DEFAULT: EnhancedSDKThemeConfiguration {
        EnhancedSDKThemeConfiguration.artiusIDDefault
    }
    
    // MARK: - Corporate Blue Theme
    
    /// Professional blue theme for corporate apps
    public static let CORPORATE_BLUE = EnhancedSDKThemeConfiguration(
        brandName: "Corporate",
        primaryColorHex: "#1565C0",
        secondaryColorHex: "#42A5F5",
        backgroundColorHex: "#F5F5F5"
    )
    
    // MARK: - Dark Theme
    
    /// Dark theme for night mode
    public static let DARK_THEME = EnhancedSDKThemeConfiguration(
        brandName: "Dark Mode",
        primaryColorHex: "#BB86FC",
        secondaryColorHex: "#03DAC6",
        backgroundColorHex: "#121212"
    )
    
    // MARK: - Banking Theme
    
    /// Professional banking theme
    public static let BANKING_THEME = EnhancedSDKThemeConfiguration(
        brandName: "Banking",
        primaryColorHex: "#004D40",
        secondaryColorHex: "#00796B",
        backgroundColorHex: "#FAFAFA"
    )
    
    // MARK: - Fintech Theme
    
    /// Modern fintech theme
    public static let FINTECH_THEME = EnhancedSDKThemeConfiguration(
        brandName: "FinTech",
        primaryColorHex: "#6200EA",
        secondaryColorHex: "#00BFA5",
        backgroundColorHex: "#FFFFFF"
    )
}

/// SDK theme configuration option
///
/// Each theme includes a `themeConfig` (ArtiusIDTheme) with color scheme and logo branding.
/// Use `SampleAppViewModel.updateTheme()` to apply a theme and automatically configure the SDK.
///
/// **For SDK Users:** Custom themes can be created using the `ThemeConfig` structure:
/// - Define color scheme (primary, secondary, background)
/// - Provide branded logos via `LogoAssetProvider`
/// - Pass to `ThemeManager.shared.setTheme()` before launching SDK flows
///
public enum ThemeOption: String, CaseIterable, Identifiable {
    case artiusDefault = "artius.iD Default"
    case corporateBlue = "Corporate Blue"
    case darkTheme = "Dark Theme"
    case bankingTheme = "Banking Theme"
    case fintechTheme = "FinTech Theme"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        return rawValue
    }
    
    public var description: String {
        switch self {
        case .artiusDefault:
            return "Default artius.iD brand colors"
        case .corporateBlue:
            return "Professional corporate theme"
        case .darkTheme:
            return "Dark mode for low-light"
        case .bankingTheme:
            return "Financial institution theme"
        case .fintechTheme:
            return "Modern fintech theme"
        }
    }
    
    public var themeConfig: EnhancedSDKThemeConfiguration {
        switch self {
        case .artiusDefault:
            return EnhancedSDKThemeConfiguration.artiusIDDefault
        case .corporateBlue:
            return SampleAppThemes.CORPORATE_BLUE
        case .darkTheme:
            return SampleAppThemes.DARK_THEME
        case .bankingTheme:
            return SampleAppThemes.BANKING_THEME
        case .fintechTheme:
            return SampleAppThemes.FINTECH_THEME
        }
    }
}
