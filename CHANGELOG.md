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

## [2.0.58] - 2025-12-08

### Changed
- **Dynamic Client Configuration**: `clientId` and `clientGroupId` can now be passed dynamically from client applications
  - Added `clientId` and `clientGroupId` as required parameters to `ArtiusIDSDK.configure()`
  - Added `clientId` and `clientGroupId` as required parameters to `ArtiusIDSDKWrapper.configure()`
  - Changed `AppConstants.clientId` and `AppConstants.clientGroupId` from `let` to `var` to allow runtime configuration
  - Client apps must now provide these values during SDK configuration instead of relying on hardcoded defaults

### Migration
- **Breaking Change**: The `configure()` method now requires `clientId` and `clientGroupId` parameters
- Update your SDK initialization call to include these parameters:
  ```swift
  ArtiusIDSDKWrapper.shared.configure(
      environment: .sandbox,
      urlTemplate: "https://#env#.#domain#",
      mobileDomain: "mobile.artiusid.dev",
      registrationUrlTemplate: "https://#env#.#domain#",
      registrationDomain: "registration.artiusid.dev",
      clientId: 123,           // ← Now required
      clientGroupId: 456,      // ← Now required
      logLevel: .info
  )
  ```

---

## [2.0.43] - 2025-12-03

### Fixed
- **CRITICAL: NFC Static Guard Prevents Polling on Subsequent Attempts** (Bug #1 from TriNet Report)
  - **Root Cause:** Static `nfcStarted` flag persists across view instances. If `onDisappear()` is not called 
    (common with UIHostingController dismissal), NFC can never start again on subsequent verification attempts.
  - **Solution:** Added public static `resetNFCState()` method to explicitly reset all NFC-related static state
    - Added `reset()` method to `NFCRetryGuard` class
    - Added `ScanChipView.resetNFCState()` public static method that resets both `nfcStarted` and `retryGuard`
    - SDK now calls `resetNFCState()` when:
      - Verification completes (success or failure) via completion screen
      - User cancels verification at any point
      - User triggers NFC recapture from document recapture screen
    - Added `handleCancelAndReset()` helper in `ArtiusIDVerificationView` for consistent cleanup
  - **Impact:** 
    - NFC polling now correctly starts on 2nd, 3rd, etc. verification attempts
    - No longer requires force-quit between verification sessions
    - Works correctly with both SwiftUI navigation AND UIHostingController wrapping
  - Modified `ScanChipView.swift`: Added `resetNFCState()`, `NFCRetryGuard.reset()`
  - Modified `ArtiusIDVerificationView.swift`: Added reset calls on completion/cancel

- **CRITICAL: Verification Screen Shows Success on Failure** (Bug #2 from TriNet Report)
  - **Root Cause:** `VerificationScreenView` used `verificationResult?.isSuccessful ?? true`, defaulting to 
    success when `verificationResult` is `nil` (can happen due to SwiftUI state timing issues).
  - **Solution:** Changed default from `true` to `false`
    - `let isSuccess = verificationResult?.isSuccessful ?? false`
    - If result state hasn't propagated, show failure instead of success
  - **Impact:**
    - Users no longer see "Verification Complete" success screen when verification actually failed
    - Prevents false positive user feedback
    - Correct error state shown if result is nil
  - Modified `VerificationScreenView.swift` line 20

### Technical Details

**NFC Reset Implementation:**
- `ScanChipView.resetNFCState()` is now public and should be called:
  - After verification completion (already handled internally by SDK)
  - On SDK dismissal/cancellation (already handled internally by SDK)
  - Can be called externally by client apps if needed for custom flows
  
- The following locations in `ArtiusIDVerificationView` now reset NFC state:
  - `completionScreenView.onComplete` - when user taps "Continue" after verification
  - `introductionView.onBack` - when user cancels from intro screen
  - `processingView.onBack` - when user cancels from processing/failure screen
  - `documentRecaptureView.onCancel` - when user cancels from recapture screen
  - `navigateToDocumentScan(.nfcTimeoutError)` - before NFC recapture

**Verification Screen Default Change:**
- Line 20 in `VerificationScreenView.swift` changed:
  - Old: `let isSuccess = verificationResult?.isSuccessful ?? true`
  - New: `let isSuccess = verificationResult?.isSuccessful ?? false`

### Known Issues (Documented, Not Fixed in This Release)
- **Issue #3: Hardcoded clientId/clientGroupId** - `AppConstants.clientId` (hardcoded to `1`) is used in 
  `VerificationResponse.swift` and `ArtiusIDSDK.swift` instead of the `configuration.clientId` passed by 
  client apps. This is a medium priority issue for a future release.

### Migration
- **No code changes required** - drop-in replacement
- All fixes are internal to the SDK
- Existing client integrations will automatically benefit from the fixes

---

## [2.0.27] - 2025-12-02

### Fixed
- **CRITICAL: NFC Duplicate Session Prevention (UIHostingController Fix)**: Fixed duplicate onAppear calls in UIHostingController
  - **Root Cause:** When ScanChipView is wrapped in UIHostingController (standard integration pattern), SwiftUI calls `onAppear` twice, creating duplicate NFC sessions
  - **Solution:** Implemented static class-level guard with NSLock for thread-safe prevention
    - Added `private static var nfcStarted` flag (persists across view instances)
    - Added `private static let nfcStartLock` (NSLock for thread safety)
    - Guard in `onAppear()` prevents multiple NFC session starts
    - `onDisappear()` resets flag to allow re-entry to screen
  - **Impact:** 
    - Prevents "System resource unavailable" (NFCError Code 203)
    - Prevents "SWIFT TASK CONTINUATION MISUSE" error
    - Ensures only ONE NFC session runs regardless of view lifecycle
    - Works with both direct SwiftUI navigation AND UIHostingController wrapping
  - **Defense in Depth:** Works in conjunction with existing `NFCRetryGuard` for complete protection
  - Modified `ScanChipView.swift` lines 67-69, 124, 133-163

- **Face Scan Retry Button Text**: Fixed placeholder text on the "Let's try again" screen
  - Changed from non-existent `"button_tryAgain"` to correct `"try_again_button"` localization key
  - Button now displays "Try Again" instead of placeholder text
  - Modified `FaceScanRetryView.swift` line 111

- **OKTA ID Back Button Navigation**: Fixed back button navigation on Okta ID input screen
  - Changed navigation from `.documentBack` to `.documentSelection`
  - Back button now correctly returns to document selection screen instead of document back scan
  - Modified `ArtiusIDVerificationView.swift` line 375

- **Document Selection Icon Theming**: Fixed icons to use theme colors instead of hardcoded orange
  - State ID and Passport icons now properly use `colorScheme.secondaryColor`
  - Icons will match client theme (e.g., TriNet Orange for TriNet clients)
  - Updated to use `.foregroundStyle()` (modern SwiftUI API)
  - Modified `SelectDocumentTypeView.swift` lines 79, 125

### Technical Details
- Modified `artiusid-sdk-ios/Views/Passport/ScanChipView.swift`:
  - **Removed** instance-level `@State private var hasStartedNFC` (doesn't work with UIHostingController)
  - **Added** static class-level guards:
    - `private static var nfcStarted = false` - Persists across view instances
    - `private static let nfcStartLock = NSLock()` - Thread-safe lock
  - **Enhanced** `onAppear()` function:
    - Thread-safe lock acquire/release around guard check
    - Prevents duplicate NFC starts even when UIHostingController calls onAppear twice
    - Comprehensive logging identifies UIHostingController as cause
  - **Added** `onDisappear()` function:
    - Resets static `nfcStarted` flag when view is dismissed
    - Allows NFC to start again if user navigates back to chip scan
    - Thread-safe flag reset with lock protection
  
- Modified `artiusid-sdk-ios/Views/Face/FaceScanRetryView.swift`:
  - Updated button localization key from `"button_tryAgain"` to `"try_again_button"`
  
- Modified `artiusid-sdk-ios/Views/PublicUI/ArtiusIDVerificationView.swift`:
  - Updated `oktaIDCollectionView` back navigation from `currentStep = .documentBack` to `currentStep = .documentSelection`

- Modified `artiusid-sdk-ios/Views/Document/SelectDocumentTypeView.swift`:
  - Changed icon colors from hardcoded `Color(hex: "#D64100")` to `colorScheme.secondaryColor`
  - Reordered modifiers: `.renderingMode(.template)` before `.resizable()` for better practice

---

## [2.0.19] - 2025-11-24

### Fixed
- **CRITICAL: Lock-Based Concurrent NFC Retry Prevention**: Added robust thread-safe guard to prevent duplicate NFC attempts
  - Introduced `NFCRetryGuard` class with NSLock-based synchronization
  - Guarantees only ONE NFC attempt can run at a time (eliminates race conditions)
  - `tryAcquire()` blocks duplicate calls if retry already in progress
  - `release()` with defer block ensures lock is ALWAYS released
  - Comprehensive logging for debugging concurrent attempt blocks
  
- **Government ID Instruction Icon Theming**: Fixed tip icons to use secondary color
  - `ScanIDIntroView`: All tip icons now use `secondaryColor` (TriNet Orange)
  - `ScanIDBackIntroView`: All tip icons now use `secondaryColor` (TriNet Orange)
  - Added `.renderingMode(.template)` for proper theming
  - Now matches passport instruction views and face scan intro view

### Technical Details
- Modified `ScanChipView.swift`:
  - Added `NFCRetryGuard` private class with NSLock
  - Added `static retryGuard` property to ScanChipView
  - Guard clause at start of `asyncFunction()` with `tryAcquire()`
  - Defer block ensures `release()` on all exit paths (success, failure, timeout, early return)
  - Prevents ALL concurrent NFC session creation attempts
- Modified `ScanIDIntroView.swift` and `ScanIDBackIntroView.swift`:
  - Changed icon foregroundColor from `onBackgroundColor` to `secondaryColor`
  - Icons: no_glare_icon, lay_flat_icon, good_light_icon, focus_icon

### Impact
- **Production-quality fix** addressing all issues from TriNet bug report
- **Zero chance of concurrent NFC sessions** (previous fix was partial)
- **Eliminates "System resource unavailable" errors** completely
- **No more duplicate log entries** ("Starting NFC attempt" printed 3x)
- **Visual consistency** across all instruction screens
- **No breaking changes** - drop-in replacement

---

## [2.0.18] - 2025-11-24

### Fixed
- **CRITICAL: NFC Session Resource Leak**: Fixed Swift continuation leak in passport NFC scanning
  - Added `PassportReader.cancelScan()` method to properly invalidate NFC session
  - Timeout handler now calls `cancelScan()` to release NFC hardware resources
  - Fixes "System resource unavailable" error (NFCError Code=203) on retry attempts
  - Fixes "SWIFT TASK CONTINUATION MISUSE" error that could cause app instability
  - Increased retry delay from 1.0s to 1.5s for proper hardware release between attempts

### Technical Details
- Modified `PassportReader.swift`: Added public `cancelScan()` method
  - Invalidates `NFCTagReaderSession` with error message
  - Resumes pending continuation with `UserCanceled` error
  - Cleans up `nfcContinuation` to prevent leaks
- Modified `ScanChipView.swift`: Timeout handler now properly cleans up NFC session
  - Calls `passportReader.cancelScan()` before retry
  - Ensures NFC hardware is available for subsequent attempts

### Impact
- **All passport verification flows**: This is a critical fix for any client using passport NFC scanning
- **No breaking changes**: Drop-in replacement, no API changes
- **Immediate deployment recommended**: Prevents app instability and failed NFC scans

---

## [2.0.17] - 2025-11-24

### Added
- **Re-verification Support**: Added `accountNumber` parameter to `VerificationRequest`
  - If a member ID exists in keychain from previous verification, it's automatically included
  - Enables re-verification flow for existing users
  - Uses environment-specific keychain key: `verification-{environment}`

### Fixed
- **Keychain Access Bug**: Fixed typo in member ID retrieval from keychain
  - Corrected key format to use proper environment-specific key
  - Added logging for re-verification attempts
  - Bug was introduced in Nelson's PR (extra parenthesis in key name)

### Technical Details
- Modified `VerificationResponse.swift` to retrieve and include existing `accountNumber`
- Added proper environment context for keychain lookups
- Updated Package.swift binary URLs to v2.0.17

---

## [2.0.16] - 2025-11-21

### Fixed
- **Government ID Scan Intro Views Layout**: Fixed horizontal centering issues
  - `ScanIDIntroView`: Refactored layout to use ScrollView with proper padding
  - `ScanIDBackIntroView`: Refactored layout to use ScrollView with proper padding
  - Content (GIF, text, table) now properly centered on all device sizes
  - Removed asymmetric padding that caused right-shift appearance
  - Fixed back button positioning with large fixed padding (45pt leading)
  - Grid header now spans both columns correctly
  - Consistent spacing between all content elements

### Technical Details
- Changed from VStack with Spacers to ScrollView-based layout
- Used `.frame(maxWidth: .infinity)` for proper horizontal centering
- Applied `.gridCellColumns(2)` to tips header for proper spanning
- Standardized padding values: leading 45pt, trailing 20pt, top 50pt
- Maintained responsive sizing with `getRelativeWidth()` and `getRelativeHeight()`

---

## [2.0.13] - 2024-11-17

### Changed
- **Navigation Back Button Redesign**: Complete UI overhaul for cleaner integration
  - Removed `CustomBackButtonView` component usage (component still exists for compatibility)
  - Back button now directly embedded in each view's layout
  - Removed all container styling: frame constraints, backgrounds, separator lines
  - Simplified to HStack with padding only (horizontal: 20pt, top: 16pt, bottom: 20pt)
  - No visual "outline" or "container" effect
  - Back button icon and text use `secondaryColor` for automatic theming
  
- **Navigation Bar Hiding Improvements**: Enhanced iOS 16+ compatibility
  - Added `.toolbar(.hidden, for: .navigationBar)` to all SDK views
  - Ensures complete hiding of system navigation bar on iOS 13-16+
  - No system UI overlays on any screen

### Fixed
- Navigation back button no longer shows system navigation bar overlay
- Back button appears cleanly without visual container on all iOS versions
- Consistent back button positioning and spacing across all SDK screens

### Technical Details
- Updated 10 SDK views with new back button implementation:
  - VerificationSteps, FaceScanIntroView, FaceScanView, FaceScanRetryView
  - ScanIDIntroView, ScanIDFrontView, ScanIDBackView, ScanIDBackIntroView
  - SelectDocumentTypeView, CollectOktaIDView
- Zero API changes - fully backward compatible
- No client code changes required

### Migration
- **No code changes required** - drop-in replacement
- Back button automatically themes with existing `secondaryColor` configuration
- Clean build recommended after update

---

## [2.0.12] - 2024-11-14

### Added
- **Okta ID Integration**: Optional Okta ID collection during verification flow
  - New `includeOktaIDInVerificationPayload` configuration parameter (default: true)
  - `CollectOktaIDView` for user input
  - Okta ID field added to `VerificationResult`
  - Conditionally included in verification API payload based on flag
  - Seamless integration into verification workflow between document scan and processing

- **Document Recapture (v2.0.6)**: Automatic retry for recoverable document errors
  - Error codes 600-604 now trigger recapture screens instead of permanent failure
  - `DocumentRecaptureType` enum with specific error types
  - `DocumentRecaptureNotificationView` with user-friendly instructions
  - New fields in `VerificationResult`: `requiresRecapture` and `recaptureType`
  - Automatic navigation back to appropriate scan screen for retry
  - Previous scan data cleared on recapture

- **Explicit Base URL Configuration (v2.0.4)**: Complete control over API endpoints
  - `baseURL` parameter (required) for mobile services
  - `registrationDomain` parameter (required) for certificate registration
  - No automatic URL construction - clients specify exact endpoints
  - Support for custom domains and proxy configurations

- **Certificate Management Improvements**:
  - Fixed certificate reloading from keychain on home page display
  - Proper environment-to-SDK enum mapping for certificate keys
  - Environment-specific certificate storage with correct rawValues

### Changed
- **SDK Configuration API**: Breaking change - new required parameters
  ```swift
  // Old (v2.0.5)
  configure(environment:, urlTemplate:, mobileDomain:, registrationUrlTemplate:, registrationDomain:)
  
  // New (v2.0.11)
  configure(environment:, baseURL:, registrationDomain:, includeOktaIDInVerificationPayload:, logLevel:)
  ```

- **Face Scan Instruction Icons**: Now use `secondaryColor` from theme for better visual hierarchy
  - Changed from background/text colors to themeable secondary color
  - Improved theming consistency across SDK

- **Verification Flow**: Added conditional Okta ID collection step
  - Face Scan → Document Scan → Okta ID (if enabled) → Processing → Completion
  - Fully backward compatible when Okta ID collection is disabled

- **Error Handling**: Improved handling of recoverable vs. permanent errors
  - Clients must check `requiresRecapture` before checking `isSuccessful`
  - Better user experience for document scanning errors

- **VerificationSteps View**: Conditionally displays "Okta ID" step based on configuration flag

### Fixed
- **Certificate Loading**: Fixed certificate not being reloaded from keychain
  - Was using display name (e.g., "sandbox") instead of SDK enum rawValue (e.g., "sandbox-env")
  - Added `mapToSDKEnvironment()` helper function
  - Certificate now properly reloads on home page display

- **Sample App UI**: Removed unnecessary elements
  - Removed settings wheel from home page
  - Removed "Test Camera Sounds" button
  - Added Okta ID configuration dropdown (enable/disable)

- **Build Configuration**: Removed hardcoded development team IDs from project file
  - Allows any developer to build without code signing errors
  - Xcode now automatically manages signing

### Documentation
- **CLIENT_IMPLEMENTATION_GUIDE.md**: Comprehensive implementation guide for v2.0.11
  - Complete feature documentation (Okta ID, document recapture, theming)
  - Full API reference
  - Best practices and troubleshooting
  - Migration guidance from previous versions

- **Documentation Cleanup**: Removed 20+ obsolete/internal documentation files
  - Consolidated all client-facing documentation into single guide
  - Removed version-specific migration guides
  - Removed internal implementation summaries

### Breaking Changes
- `baseURL` parameter now required (was `urlTemplate`)
- `registrationDomain` parameter now required (no template system)
- Removed template-based URL construction (use explicit URLs)

### Migration from v2.0.5
See [CLIENT_IMPLEMENTATION_GUIDE.md](CLIENT_IMPLEMENTATION_GUIDE.md) for complete migration guide.

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

