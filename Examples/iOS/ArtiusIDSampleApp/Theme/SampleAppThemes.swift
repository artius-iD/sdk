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

/// Sample theme configurations - MATCHING Android SDK exactly
public struct SampleAppThemes {
    
    // MARK: - artius.iD Default Theme (MATCHING Android)
    
    /// artius.iD Default Theme - Using system colors from DefaultTheme
    public static let ARTIUSID_DEFAULT = EnhancedSDKThemeConfiguration(
        brandName: "artius.iD",
        
        typography: SDKTypography(
            headlineLarge: 32,
            headlineMedium: 28,
            titleLarge: 22,
            bodyLarge: 16,
            bodyMedium: 14,
            headlineWeight: "bold",
            titleWeight: "medium",
            bodyWeight: "normal"
        ),
        
        colorScheme: SDKColorScheme(
            // Primary colors from DefaultTheme - using system colors
            primaryColorHex: "#000000",        // .primary text color
            secondaryColorHex: "#007AFF",     // .blue for icons and navigation
            backgroundColorHex: "#FFFFFF",    // systemBackground
            surfaceColorHex: "#F2F2F7",       // secondarySystemBackground
            onPrimaryColorHex: "#FFFFFF",     // White text on dark background
            onSecondaryColorHex: "#FFFFFF",   // White text on blue background
            onBackgroundColorHex: "#000000",  // Dark text on white background
            onSurfaceColorHex: "#000000",     // Dark text on light surface
            successColorHex: "#34C759",       // .green
            errorColorHex: "#FF3B30",         // .red
            warningColorHex: "#FF9500",       // .orange
            // Button colors using secondary (blue)
            primaryButtonColorHex: "#007AFF",     // Blue button
            primaryButtonTextColorHex: "#FFFFFF", // White text
            secondaryButtonColorHex: "#F2F2F7",   // Light gray button
            secondaryButtonTextColorHex: "#000000" // Dark text
        ),
        
        iconTheme: SDKIconThemeConfig(
            iconStyle: "filled",
            mediumIconSize: 24,
            // Core icon colors from DefaultTheme
            primaryIconColorHex: "#007AFF",     // .blue
            secondaryIconColorHex: "#3C3C43",   // .secondary
            accentIconColorHex: "#007AFF",      // .accentColor (blue)
            disabledIconColorHex: "#ADB5BD",    // .gray
            
            // Navigation & UI Icons from DefaultTheme
            navigationIconColorHex: "#007AFF",  // .blue
            actionIconColorHex: "#007AFF",      // .blue
            
            // Instruction & Guide Icons
            instructionIconColorHex: "#FF9500", // .orange
            warningIconColorHex: "#FF9500",     // .orange
            errorIconColorHex: "#FF3B30",       // .red
            successIconColorHex: "#34C759",     // .green
            
            // Document & Verification Icons
            documentIconColorHex: "#007AFF",    // .blue
            cameraIconColorHex: "#007AFF",      // .blue
            scanIconColorHex: "#AF52DE",        // .purple
            
            // Biometric & Security Icons
            biometricIconColorHex: "#34C759",   // .green
            securityIconColorHex: "#007AFF",    // .blue
            nfcIconColorHex: "#30B0C0",         // .teal
            
            // Status Icons
            statusActiveIconColorHex: "#34C759",    // .green
            statusInactiveIconColorHex: "#ADB5BD", // .gray
            statusProcessingIconColorHex: "#FF9500" // .orange
        ),
        
        textContent: SDKTextContent(
            welcomeTitle: "artius.iD Verification",
            welcomeSubtitle: "Secure identity verification powered by artius.iD",
            documentScanTitle: "Scan Your ID",
            passportScanTitle: "Scan Your Passport",
            faceScanTitle: "Face Verification",
            processingTitle: "Processing",
            verificationSuccessTitle: "Verification Complete"
        ),
        
        componentStyling: SDKComponentStyling(
            buttonCornerRadius: 12,
            cardCornerRadius: 12,
            buttonHeight: 48
        ),
        
        layoutConfig: SDKLayoutConfig(
            screenPadding: 16,
            componentSpacing: 16
        ),
        
        animationConfig: SDKAnimationConfig(
            mediumAnimationDuration: 300,
            pageTransitionStyle: "slide"
        )
    )
    
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
            return SampleAppThemes.ARTIUSID_DEFAULT
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
