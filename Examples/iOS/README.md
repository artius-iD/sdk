# ArtiusID iOS Sample App

Complete example demonstrating how to integrate the ArtiusID SDK into an iOS application.

## 🎯 What's Included

This sample app showcases:

- ✅ **Identity Verification Flow** - Face scan + government ID verification
- ✅ **Biometric Authentication** - Face-based auth for returning users
- ✅ **Push Notifications** - Firebase Cloud Messaging integration
- ✅ **Theme Customization** - 5 pre-configured themes
- ✅ **Multi-Language Support** - English, Spanish, French
- ✅ **Environment Switching** - Dev, Staging, Production, Sandbox, QA
- ✅ **Error Handling** - Document recapture and retry flows

## 📋 Prerequisites

- **Xcode 15.0+**
- **iOS 14.0+** device or simulator
- **Firebase Project** (for push notifications)
- **ArtiusID Credentials** (contact support@artiusid.dev)

## 🚀 Setup Instructions

### Option 1: Using Swift Package Manager (Public Users)

If you cloned the GitHub repository, use this approach:

```bash
cd Examples/iOS
swift package resolve
open -a Xcode .
```

**What happens:**
- SPM automatically downloads the binary SDK from GitHub releases
- Xcode opens the sample app as an SPM package
- Select build scheme and run

### Option 2: Using Xcode Workspace (Contributors/Internal Users)

If you have access to both the SDK source and sample app:

```bash
cd ..
open ../../artiusid-sdk-ios/artiusid-sdk-ios.xcodeproj
```

**What happens:**
- Opens the workspace with SDK source + sample app
- Sample app builds against local SDK source
- Good for understanding SDK internals or contributing

---

## 🔧 Before Running the App

### 1. Configure Firebase

The sample app requires Firebase for push notifications:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an iOS app with bundle ID: `com.artiusid.artius-iD-Sample-App`
3. Download `GoogleService-Info.plist`
4. Replace `ArtiusIDSampleApp/GoogleService-Info.plist` with your file

⚠️ **Note:** The included `GoogleService-Info.plist` contains placeholder values. The app will build but push notifications won't work without a valid configuration.

### 2. Update Client Credentials

In `ArtiusIDSampleApp/SampleApp.swift`, find the verification configuration and update:

```swift
ArtiusIDVerificationView.Configuration(
    clientId: YOUR_CLIENT_ID,  // Replace with your actual client ID
    environment: .staging
)
```

Get your `clientId` from artius.iD support: support@artiusid.dev

### 3. Build & Run

Press **⌘R** in Xcode or:

```bash
xcodebuild -scheme "artius.iD Sample App" -destination "generic/platform=iOS"
```

## 🎨 Key Features Demo

### Verify a User
Navigate to the Verification tab and tap "Start Verification". The app will:
1. Launch the verification view
2. Prompt for face scan
3. Request government ID photo/scan
4. Display verification result

### Authenticate a User
Navigate to the Authentication tab and tap "Start Authentication". The app will:
1. Use biometric/passcode authentication
2. Display authentication result

### Customize the Theme
Go to Settings → Theme and select from:
- artius.iD Default (system colors)
- Dark Theme
- Corporate Blue
- High Contrast
- Minimal

## 📂 Project Structure

```
ArtiusIDSampleApp/
├── SampleApp.swift              # App entry point, Firebase setup
├── Views/
│   ├── SampleAppView.swift      # Main UI demonstrating SDK flows
│   └── SampleAppSettingsView.swift  # Configuration settings
├── Models/
│   └── SampleAppViewModel.swift # SDK initialization & state
├── Config/
│   ├── AppPreferences.swift     # Type-safe UserDefaults wrapper
│   ├── EnvironmentConfig.swift  # Environment definitions
│   └── SampleImageOverrides.swift # Custom image assets
├── Theme/
│   └── SampleAppThemes.swift    # 5 theme configurations
├── Services/
│   └── SampleFirebaseMessagingService.swift # FCM delegate
└── GoogleService-Info.plist     # Firebase config (placeholder)
```

## 🔧 Configuration Files

### AppPreferences.swift
Type-safe wrapper for UserDefaults. Store and retrieve app settings:
```swift
AppPreferences.set("en", forKey: .appLanguage)
let language = AppPreferences.get(forKey: .appLanguage)
```

### EnvironmentConfig.swift
Defines available SDK environments:
```swift
case development, staging (default), production, sandbox, qa
```

### SampleAppThemes.swift
5 complete theme definitions. Customize colors and fonts:
```swift
ThemeOption.artiusDefault    // System-based colors
ThemeOption.darkTheme        // Dark mode
ThemeOption.corporateBlue    // Professional blue
ThemeOption.highContrast     // Accessibility
ThemeOption.minimal          // Clean & minimal
```

## 🐛 Troubleshooting

### Build Errors

**"Package resolution failed" or "SDK not found" (SPM users):**
```bash
# Clean and resolve again
rm -rf .build .swiftpm
swift package resolve
open -a Xcode .
```

**"Missing SDK" or package resolution fails (Workspace users):**
```bash
# Clean build folder
cd ../../artiusid-sdk-ios
rm -rf .build build
# Reopen project in Xcode
```

**Code signing issues:**
- Go to project settings → Signing & Capabilities
- Select your development team
- Update bundle identifier if needed

### Runtime Issues

**Firebase errors on launch:**
- Ensure `GoogleService-Info.plist` is valid (not the placeholder)
- Check bundle ID matches your Firebase project

**Verification fails immediately:**
- Verify `clientId` is set correctly in SampleApp.swift
- Check network connectivity
- Ensure selected environment is correct

**Certificate errors:**
- Check environment matches your SDK registration certificates
- Contact support@artiusid.dev for certificate help

## 📚 Learn More

- **Main SDK Documentation:** [../../README.md](../../README.md)
- **API Reference:** See main README for complete SDK API documentation
- **Theme Guide:** [THEMING_GUIDE.md](../../THEMING_GUIDE.md) (in docs/)
- **Changelog:** [CHANGELOG.md](../../CHANGELOG.md)

## 💬 Support

- **Email:** support@artiusid.dev
- **GitHub Issues:** [Report an issue](https://github.com/artius-iD/sdk/issues)

## 📄 License

This sample application is provided as-is under the same license as the ArtiusID SDK.
