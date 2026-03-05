//
//  SampleImageOverrides.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 10/29/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import Foundation
import artiusid_sdk_ios

/// Sample image override configurations demonstrating brand customization.
/// Shows how to customize images for branding purposes.
/// Images referenced here should be added to Assets.xcassets with the specified names.
///
/// **Sources:**
/// - Icons sourced from https://feathericons.com/ (free, MIT license)
/// - Custom overlays can be created as PDF or PNG with 2x/3x resolution scaling
///
public struct SampleImageOverrides {
    
    // MARK: - Branded Override Example
    /// Example of a branded override with custom images.
    /// Demonstrates how to customize key visual elements for branding.
    public static let brandedOverride: SDKImageOverrides = SDKImageOverrides(
        // Navigation Icons
        backButtonIcon: "custom_nav_back",          // Custom back button
        cameraButtonIcon: "custom_action_camera",   // Custom camera button
        scanFaceIcon: "custom_icon_face_scan",      // Custom face scan icon
        docScanIcon: "custom_icon_doc_scan",        // Custom document scan icon
        doneIcon: "custom_nav_done",                // Custom done/completion icon
        
        // Status Icons
        successIcon: "custom_status_success",       // Custom success icon
        failedIcon: "custom_status_failed",         // Custom failed icon
        errorIcon: "custom_status_error",           // Custom error icon
        approvalIcon: "custom_status_approval",     // Custom approval icon
        declinedIcon: "custom_status_declined",     // Custom declined icon
        
        // Branding
        brandLogo: "custom_logo",                   // Custom brand logo
        brandImage: "custom_brand_image",           // Custom brand image
        
        // Document Type Icons
        passportIcon: "custom_doc_passport",        // Custom passport icon
        stateIdIcon: "custom_doc_id"                // Custom ID icon
    )

    // MARK: - Feather-Like Override Example
    /// Feather-style override using monochrome line-style icons.
    /// Useful for comparing branded filled icons vs minimalist iconography.
    public static let featherLikeOverride: SDKImageOverrides = SDKImageOverrides(
        // Navigation Icons
        backButtonIcon: "feather_nav_back",
        cameraButtonIcon: "feather_action_camera",
        scanFaceIcon: "feather_icon_face_scan",
        docScanIcon: "feather_icon_doc_scan",
        doneIcon: "feather_nav_done",

        // Status Icons
        successIcon: "feather_status_success",
        failedIcon: "feather_status_failed",
        errorIcon: "feather_status_error",
        approvalIcon: "feather_status_approval",
        declinedIcon: "feather_status_declined",

        // Branding
        brandLogo: "feather_logo",
        brandImage: "feather_brand_image",

        // Document Type Icons
        passportIcon: "feather_doc_passport",
        stateIdIcon: "feather_doc_id"
    )
}


/// Image override configuration option
///
/// Demonstrates different ways to customize icons, buttons, logos, and status indicators
/// throughout the SDK verification, authentication, and approval flows.
///
/// **For SDK Users:** To add image overrides:
/// 1. Define custom image names in your app's asset catalog
/// 2. Create an `SDKImageOverrides` configuration with your asset names
/// 3. Call `ImageOverrideManager.shared.setConfiguration(overrides)` before launching SDK flows
/// 4. Use `clearOverrides()` to revert to SDK defaults
///
/// See `SampleImageOverrides` for example configurations.
///
public enum ImageOverrideOption: String, CaseIterable, Identifiable {
    case `default` = "Default"
    case override = "Branded Override"
    case featherLike = "Feather Like"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        return rawValue
    }
    
    /// Human-readable description of what this scenario demonstrates
    public var description: String {
        switch self {
        case .default:
            return "Use all SDK default images"
        case .override:
            return "Demonstrate branded image overrides with custom icons"
        case .featherLike:
            return "Demonstrate Feather-like monochrome line icons"
        }
    }
    
    /// The actual override configuration for this scenario
    public var overrides: SDKImageOverrides? {
        switch self {
        case .default:
            return nil
        case .override:
            return SampleImageOverrides.brandedOverride
        case .featherLike:
            return SampleImageOverrides.featherLikeOverride
        }
    }
    
    /// Number of image properties customized in this scenario
    public var customizationCount: Int {
        switch self {
        case .default:
            return 0
        case .override, .featherLike:
            return 14  // 14 properties customized
        }
    }
}
