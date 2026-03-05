# ArtiusID Sample Application

A production-quality iOS sample application demonstrating best practices for integrating the ArtiusID SDK.

## Overview

This sample app showcases:

- Complete SDK public API integration
- Multi-language support (English, Spanish, French)
- Theme customization with 5 pre-configured themes
- Environment management (Dev, Staging, Production, Sandbox, QA)
- Firebase Cloud Messaging integration
- Persistent user preferences

## Quick Start

### Prerequisites

- Xcode 15.0+
- iOS 14.0+ deployment target
- ArtiusID SDK framework (included in parent project)

### Building & Running

1. **Open the project:**

   ```bash
   cd ArtiusIDSampleApp
   open ../artiusid-sdk-ios.xcodeproj
   ```

2. **Select target:** Choose "ArtiusID Sample App" from the scheme selector

3. **Run:** Press ⌘R or click the Run button

## Features

### 🌐 Multi-Language Support

The app supports three languages with complete localization:

- **English** (en)
- **Spanish** (es-ES)  
- **French** (fr)

All 51 localization keys are synchronized across languages. Change language in Settings → Language.

### 🎨 Theme System

5 pre-configured themes are available:

1. **artius.iD Default** - System colors (black primary, blue secondary)
2. **Dark Theme** - Dark mode aesthetic
3. **Corporate Blue** - Professional blue theme
4. **High Contrast** - Accessibility-focused
5. **Minimal** - Clean, minimal design

Themes are persisted across app restarts. Access via Settings → Theme.

### 🔄 Environment Management

Switch between environments without rebuilding:

- Development
- Staging (default)
- Production
- Sandbox
- QA

Environment selection is persisted and affects:

- API endpoints
- Keychain storage keys
- FCM token management

Access via Settings → Environment.

### 📱 SDK Integration Examples

#### Verification Flow

```swift
ArtiusIDVerificationView(
    configuration: ArtiusIDVerificationView.Configuration(
        clientId: 12345,
        environment: .staging,
        preferredDocumentType: .passport
    ),
    onCompletion: { result in
        // Handle verification result
    },
    onCancel: {
        // Handle cancellation
    }
)
```

#### Authentication Flow

```swift
ArtiusIDAuthenticationView(
    configuration: ArtiusIDAuthenticationView.Configuration(
        clientId: 12345,
        clientGroupId: 1,
        accountNumber: "test-account",
        environment: .staging
    ),
    onCompletion: { result in
        // Handle authentication result
    },
    onCancel: {
        // Handle cancellation
    }
)
```

#### Approval Flow

```swift
ArtiusID.ApprovalView(
    onCompletion: { result in
        // result: "yes", "no", "cancelled", or "approval_failed"
    },
    onCancel: {
        // Handle cancellation
    }
)
```

## Project Structure

```text
ArtiusIDSampleApp/
├── Views/
│   ├── SampleAppView.swift           # Main view with SDK flow triggers
│   └── SampleAppSettingsView.swift   # Settings modal
├── Models/
│   └── SampleAppViewModel.swift      # View model with SDK interactions
├── Config/
│   └── GoogleService-Info.plist      # Firebase configuration
├── Theme/
│   └── SampleAppThemes.swift         # Theme definitions
├── Resources/
│   └── [lang].lproj/                 # Localization files (SDK bundle)
├── Assets.xcassets/                  # App assets
├── Info.plist                        # App configuration
└── SampleApp.swift                   # App entry point with managers
```

## Key Components

### LanguageManager

Singleton managing app language with 3-tier fallback:

1. Sample App bundle
2. SDK framework bundle
3. Return key as fallback

```swift
// Change language
LanguageManager.shared.setLanguage(code: "es-ES")

// Localize text
let text = LanguageManager.shared.localize("sample_verification")
```

### AppThemeManager

Singleton managing theme persistence:

```swift
// Change theme
AppThemeManager.shared.currentTheme = .dark

// Observe changes
@EnvironmentObject var themeManager: AppThemeManager
```

### SampleAppViewModel

Manages SDK interactions and state:

- FCM token management
- Credential storage/retrieval
- SDK initialization
- Environment switching

## Customization

### Adding a New Language

1. Add localization file: `Resources/[lang-code].lproj/Localizable.strings`
2. Add to SDK bundle as well: `../artiusid-sdk-ios/Resources/[lang-code].lproj/`
3. Update `LanguageManager.supportedLanguages`
4. Add display name to localization keys: `language_[name]`

### Creating a Custom Theme

1. Open `Theme/SampleAppThemes.swift`
2. Add new theme to `SampleAppTheme` struct
3. Configure colors, fonts, and icons
4. Add to `SampleAppViewModel.availableThemes`
5. Add theme name to localizations

### Environment Configuration

Environments are configured in the SDK's `Environments.swift`. The sample app reads from `EnvironmentManager.shared.availableEnvironments`.

## Firebase Setup

The sample app includes Firebase for push notifications:

1. **Add your GoogleService-Info.plist** to `Config/`
2. **Update Bundle ID** in Info.plist to match Firebase project
3. **Enable Push Notifications** in Xcode capabilities
4. **Test FCM token** via "Refresh FCM Token" button

## Best Practices Demonstrated

✅ **Public API Usage** - Uses only public SDK views (no internal components)  
✅ **Error Handling** - Proper completion and cancellation handling  
✅ **State Management** - @StateObject and @EnvironmentObject patterns  
✅ **Persistent Storage** - UserDefaults for preferences, Keychain for credentials  
✅ **Localization** - Complete multi-language support  
✅ **Theming** - Dynamic theme application  
✅ **Navigation** - Sheet and fullScreenCover presentations

## Known Behaviors

### Language Change Closes Settings

When changing language in settings, the settings modal automatically closes and returns to the main screen. This is expected behavior due to SwiftUI view hierarchy rebuilding when `@EnvironmentObject` changes. User preferences are saved.

## Troubleshooting

### Build Errors

#### "Cannot find 'ArtiusIDVerificationView' in scope"

- Ensure the SDK framework is properly linked
- Check that `artiusid-sdk-ios` target is built first
- Verify framework search paths in Build Settings

#### "No such module 'artiusid_sdk_ios'"

- Clean build folder (⌘⇧K)
- Rebuild SDK framework
- Restart Xcode

### Runtime Issues

#### "FCM token not appearing"

- Verify GoogleService-Info.plist is present
- Check Bundle ID matches Firebase project  
- Ensure push notification capability is enabled
- Check device network connection

#### "Localization showing keys instead of text"

- Verify localization files exist in Resources/
- Check SDK bundle includes localization files
- Confirm language code matches file naming (e.g., "es-ES.lproj")

## Contributing

This sample app is part of the ArtiusID SDK distribution. When updating:

1. Ensure all SDK public API calls remain valid
2. Update localization files for all languages
3. Test all flows (Verification, Authentication, Approval)
4. Verify theme changes apply correctly
5. Test environment switching

## Related Documentation

- [Client Implementation Guide](../CLIENT_IMPLEMENTATION_GUIDE.md) - Complete SDK integration guide
- [Theming Guide](../THEMING_GUIDE.md) - Theme customization details
- [SDK README](../README.md) - SDK build and distribution

## Support

For issues related to:

- **SDK functionality** - Review SDK documentation and guides
- **Sample app bugs** - Check GitHub issues
- **Integration questions** - See Client Implementation Guide

---

**Version:** Matches parent SDK version  
**Last Updated:** February 2026
