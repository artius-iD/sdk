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

### 1. Clone Repository

```bash
git clone https://github.com/artius-iD/sdk
cd sdk/Examples/iOS
```

### 2. Configure Firebase

The sample app requires Firebase for push notifications:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an iOS app with bundle ID: `com.artiusid.artius-iD-Sample-App`
3. Download `GoogleService-Info.plist`
4. Replace `ArtiusIDSampleApp/GoogleService-Info.plist` with your file

⚠️ **Note:** The included `GoogleService-Info.plist` contains placeholder values. The app will build but push notifications won't work without a valid configuration.

### 3. Open Project

```bash
# Option 1: Open via command line
open ../../artiusid-sdk-ios/artiusid-sdk-ios.xcodeproj

# Option 2: Open via Xcode
# File > Open > Navigate to artiusid-sdk-ios.xcodeproj
```

### 4. Select Scheme

In Xcode, select **"artius.iD Sample App"** from the scheme dropdown (top-left, next to Run button).

### 5. Run

Press **⌘R** or click the **Run** button.

## 🎨 Key Features Demo

### Verification Flow
Launch verification with face scan + ID document:
```swift
ArtiusIDVerificationView(
    configuration: .init(
        clientId: 12345,
        environment: .staging,
        preferredDocumentType: .passport
    ),
    onCompletion: { result in
        print("Verified: \(result.accountNumber)")
    }
)
```

### Authentication Flow
Biometric authentication for returning users:
```swift
ArtiusIDAuthenticationView(
    configuration: .init(
        accountNumber: "user-account-123",
        environment: .staging
    ),
    onCompletion: { result in
        print("Authenticated: \(result.accountNumber)")
    }
)
```

### Theme Customization
See `Theme/SampleAppThemes.swift` for 5 pre-configured themes:
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
│   └── SampleAppThemes.swift    # Theme configurations
├── Services/
│   └── SampleFirebaseMessagingService.swift # FCM delegate
└── GoogleService-Info.plist     # Firebase config (placeholder)
```

## 🔧 Configuration

### Update Client Credentials

In `Views/SampleAppView.swift`, update the verification configuration:

```swift
ArtiusIDVerificationView.Configuration(
    clientId: YOUR_CLIENT_ID,  // Get from artius.iD support
    environment: .staging
)
```

### Change Environment

Use Settings → Environment to switch between:
- Development
- Staging (default)
- Production
- Sandbox
- QA

### Customize Theme

Access Settings → Theme to try different visual styles or modify `Theme/SampleAppThemes.swift` to create custom themes.

## 🐛 Troubleshooting

### Build Errors

**"Missing SDK" or package resolution fails:**
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
- Verify `GoogleService-Info.plist` is valid (not the placeholder)
- Check bundle ID matches Firebase project configuration

**Verification fails immediately:**
- Ensure `clientId` matches your artius.iD credentials
- Check network connectivity
- Verify selected environment is correct

**Certificate errors:**
- Check environment matches your registered certificates
- Contact support for certificate provisioning

## 📚 Learn More

- **Main Documentation:** [../README.md](../../README.md)
- **API Reference:** See main README for complete SDK API documentation
- **Theme Guide:** [THEMING_GUIDE.md](../../THEMING_GUIDE.md) (if available in docs/)
- **Changelog:** [CHANGELOG.md](../../CHANGELOG.md)

## 💬 Support

- **Email:** support@artiusid.dev
- **Issues:** [GitHub Issues](https://github.com/artius-iD/sdk/issues)

## 📄 License

See [LICENSE](../../LICENSE) for details.
