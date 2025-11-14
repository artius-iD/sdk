# Changelog

All notable changes to the ArtiusID iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

---

## [2.0.5] - 2025-11-12

### Added
- **Template-Based URL Configuration**: Flexible URL template system for environment management
  - Separate `urlTemplate` and domain parameters for mobile and registration services
  - Token-based system with `#env#` and `#domain#` placeholders
  - Support for both new (sandbox) and legacy (dev/staging) URL patterns
  - `CUSTOMER_IMPLEMENTATION_GUIDE.md` - Comprehensive implementation guide for customers
  - `MIGRATION_GUIDE_v2.0.5.md` - Migration guide from previous versions

### Changed
- **SDK Configuration API**: Updated `configure()` method signature
  - Now accepts 5 parameters: `environment`, `urlTemplate`, `mobileDomain`, `registrationUrlTemplate`, `registrationDomain`
  - Provides explicit control over both mobile and registration service URLs
  - Breaking change: Clients must update configuration calls
- **Sample App**: Updated to demonstrate new template-based configuration pattern

### Fixed
- **UI Consistency**: Improved instruction tip cells across all scan intro views
  - Fixed small "Remove glasses" text by removing `minimumScaleFactor`
  - Added fixed height (50) to all tip cells for uniform sizing
  - Increased font size from 14 to 16 for better readability
  - Fixed empty cells to match height of cells with content
  - Applied consistent styling to FaceScanIntroView, FaceScanRetryView, ScanChipIntroView, ScanIDIntroView, and ScanIDBackIntroView

### Documentation
- **Customer Implementation Guide**: Added comprehensive guide with examples for all environments
- **Migration Guide**: Created detailed v2.0.5 migration guide with before/after comparisons
- **Internal Documentation**: Moved TriNet-specific and internal docs to .gitignore

---

## [2.0.1] - 2025-11-10

### Fixed
- **Documentation**: Updated CLIENT-README.md version references from 1.0.x to 2.0.x
  - Updated SDK version badge to show 2.0.x
  - Updated SPM installation examples to use version 2.0.0
  - Updated version range recommendations (2.0.0 < 3.0.0)

---

## [2.0.0] - 2025-11-10

### Added
- **Theme System**: Comprehensive theming support with customizable colors, fonts, and styles
  - 5+ pre-built themes (Corporate Blue, Dark Professional, Banking, FinTech, ArtiusID Default)
  - `SDKThemeConfiguration` protocol for creating custom themes
  - Real-time theme switching capability
  - `ColorManager` for centralized color management

- **Approval/Deny Workflow**: FCM-triggered approval requests with biometric authentication
  - `ApprovalRequestView` with Face ID/Touch ID integration
  - `ApprovalResponseView` for displaying approval results
  - Automatic retry logic for failed biometric authentication (up to 3 attempts)
  - Full Android SDK parity for approval flow

- **Image Override System**: Flexible image replacement strategies
  - Support for Assets.xcassets, remote URLs, and local file paths
  - `SDKImageOverrides` configuration system
  - `ImageLoader` with caching and async loading

- **Multi-language Support**: Enhanced localization infrastructure
  - English (en), Spanish (es-ES), and French (fr) translations
  - `SDKLocalization` configuration system
  - Custom text style support

- **Environment Management**: Runtime environment switching
  - Sandbox, UAT, and Production environments
  - Environment-specific keychain management
  - `EnvironmentManager` for centralized configuration

- **Biometric Authentication**: Secure authentication using Face ID/Touch ID
  - `LocalAuthentication` framework integration
  - Configurable retry attempts
  - User cancellation handling

- **Comprehensive Documentation**:
  - `CLIENT-README.md` with step-by-step integration guide
  - Code examples for all major features
  - Theming, localization, and FCM setup instructions

### Changed
- **NFC Retry Mechanism**: Automatic retry for NFC scans (removed manual retry page)
  - Up to 3 automatic retry attempts with 1-second delay
  - Seamless user experience without manual intervention

- **Verification Result Screen**: Enhanced to match Android SDK design
  - Detailed score display (face match, document, anti-spoofing, person search)
  - Status badges for document verification
  - Scrollable layout for comprehensive results

- **Error Handling**: Standardized error system
  - New `SDKError` and `SDKErrorCode` structures
  - Specific handling for "account not active" errors with 800 support number
  - Improved error messages and user feedback

- **Keychain Management**: Environment-specific keys
  - Member IDs stored with environment prefix (e.g., `verification-sandbox`)
  - Automatic cleanup on account deactivation
  - Improved multi-environment support

- **Navigation Flow**: Improved user flow
  - "Back Home" button on failure dismisses SDK modal (returns to app)
  - Cancellation properly resets loading states
  - Consistent navigation across verification and authentication flows

- **UI/UX Improvements**:
  - Document type labels: "State ID" → "Government ID", "Passport" → "Government Passport"
  - Increased top padding on verification screens (avoid camera notch)
  - Consistent text sizing in tips tables (font size 18, minimumScaleFactor 0.5)
  - Themed information icons (use secondary color)
  - Uniform grid cell sizing (including empty cells)

- **FCM Notification Handling**: Improved notification behavior
  - Approval screens only open when user taps notification (not on foreground arrival)
  - Proper notification state management
  - `AppNotificationState` with default values

### Fixed
- **Member ID Persistence**: Fixed keychain storage for verification results
  - Now correctly saves with environment-specific keys
  - Sample app properly displays updated member IDs

- **Loading State**: Fixed persistent loading spinner
  - Added `cancellation` callback to reset `isLoading` state
  - Proper cleanup on verification/authentication completion or cancellation

- **NFC Scan View**: Removed placeholder text
  - Added proper localization keys for `passport_mrz_navTitle` and `passport_mrz_bullet`

- **Approval Flow**:
  - Fixed automatic screen opening (now requires user tap on notification)
  - Removed placeholder text from approval buttons and messages
  - Fixed API response decoding (`isLambdaResponse: false` for direct response)
  - Flexible type handling for API fields (Int or String)

- **UI Layout**:
  - Fixed text sizing inconsistencies in face scan, passport scan, and NFC scan instruction pages
  - Fixed empty cell sizing in tips grids
  - Fixed information icon not using theme's secondary color

### Removed
- **Manual NFC Retry Page**: Removed `chipRetry` step from verification flow
  - Replaced with automatic retry mechanism

---

## [1.0.245] - 2024-XX-XX

### Added
- Initial public release
- Document verification (ID, Passport with NFC)
- Face verification with liveness detection
- Basic theme support
- English and Spanish localization

### Changed
- Various UI improvements
- Performance optimizations

### Fixed
- Multiple bug fixes and stability improvements

---

## Version History

- **v2.0.0** - Major feature release (Theme system, Approval flow, Multi-language, Image overrides)
- **v1.0.245** - Previous stable release
- **v1.0.244** - Previous stable release
- **v1.0.243** - Previous stable release
- **v1.0.242** - Previous stable release
- **v1.0.241** - Previous stable release

---

## Future Roadmap

### Planned Features
- Additional language support (German, Portuguese, Chinese)
- Enhanced biometric fallback options
- Advanced theme templates
- Offline verification support
- Improved accessibility features
- Performance monitoring and analytics

### Breaking Changes
- None currently planned

---

## Migration Guide

### Upgrading from v1.x to v2.0

#### Required Changes
None - v2.0 is backward compatible with v1.x

#### Recommended Changes
1. **Add Theme Configuration** (optional but recommended):
   ```swift
   ArtiusIDSDK.shared.setTheme(.defaultTheme)
   ```

2. **Update Info.plist** for biometric authentication:
   ```xml
   <key>NSFaceIDUsageDescription</key>
   <string>ArtiusID uses Face ID for biometric authentication.</string>
   ```

3. **Configure FCM** for approval/deny workflow (if using):
   - Add `GoogleService-Info.plist` to your project
   - Set up `UNUserNotificationCenterDelegate`
   - Configure `AppNotificationState` as shown in documentation

#### New Features (Optional)
- Custom themes via `SDKThemeConfiguration`
- Image overrides via `SDKImageOverrides`
- Custom localizations via `SDKLocalization`
- Environment switching via `environment` property

---

## Support

For questions or issues, please contact:
- **Email**: support@artiusid.dev
- **Documentation**: https://github.com/artius-iD/sdk
- **Issues**: https://github.com/artius-iD/sdk/issues

---

## License

Copyright © 2024-2025 ArtiusID. All rights reserved.

