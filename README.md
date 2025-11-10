# ArtiusID iOS SDK

**Version:** 1.0.x  
**Minimum iOS Version:** iOS 14.0+  
**Swift:** 5.9+

Enterprise-grade identity verification SDK for iOS applications. Provides document scanning, face verification, NFC passport reading, and biometric authentication capabilities.

---

## 📦 Installation

### Swift Package Manager (Recommended)

#### **Adding to Xcode Project**

1. **Open Your Project in Xcode**
   - Launch Xcode and open your `.xcodeproj` or `.xcworkspace`

2. **Add Package Dependency**
   - Go to **File** → **Add Package Dependencies...**
   - Or select your project in the navigator → **Package Dependencies** tab → **+** button

3. **Enter Repository URL**
   ```
   https://github.com/artius-iD/sdk
   ```

4. **Select Version**
   - **Dependency Rule:** Up to Next Major Version
   - **Version:** 1.0.0 < 2.0.0 (recommended)
   - Click **Add Package**

5. **Add to Target**
   - Select **ArtiusIDSDK** from the list
   - Choose your app target
   - Click **Add Package**

#### **Package.swift (For SPM Libraries)**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [.iOS(.v14)],
    dependencies: [
        .package(
            url: "https://github.com/artius-iD/sdk",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "ArtiusIDSDK", package: "sdk")
            ]
        )
    ]
)
```

---

## 🚀 Quick Start

### **1. Import the SDK**

```swift
import ArtiusIDSDK
```

### **2. Configure Info.plist Permissions**

Add these required permissions to your `Info.plist`:

```xml
<!-- Camera Access (Required) -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan your document and verify your identity.</string>

<!-- Face ID (Required for Biometric Auth) -->
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to securely authenticate approval requests.</string>

<!-- NFC (Required for Passport Scanning) -->
<key>NFCReaderUsageDescription</key>
<string>We need NFC access to read your passport chip information.</string>
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
</array>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A0000002471001</string>
</array>
```

### **3. Initialize the SDK**

```swift
import SwiftUI
import ArtiusIDSDK

@main
struct YourApp: App {
    init() {
        // Initialize SDK with your credentials
        ArtiusIDSDK.shared.initialize(
            clientId: YOUR_CLIENT_ID,
            clientGroupId: YOUR_CLIENT_GROUP_ID,
            environment: .sandbox  // Use .production for live
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### **4. Start Verification Flow**

```swift
import ArtiusIDSDK

struct ContentView: View {
    @State private var showVerification = false
    
    var body: some View {
        Button("Start Verification") {
            showVerification = true
        }
        .fullScreenCover(isPresented: $showVerification) {
            ArtiusIDVerificationView(
                configuration: .init(
                    clientId: YOUR_CLIENT_ID,
                    clientGroupId: YOUR_CLIENT_GROUP_ID,
                    environment: .sandbox
                ),
                onCompletion: { result in
                    if result.isSuccessful {
                        print("✅ Verification successful!")
                        print("Account: \(result.accountNumber ?? "N/A")")
                    } else {
                        print("❌ Verification failed: \(result.errorMessage ?? "Unknown")")
                    }
                    showVerification = false
                },
                onCancel: {
                    print("User cancelled verification")
                    showVerification = false
                }
            )
        }
    }
}
```

---

## 🎨 Customization

### **Theme Configuration**

Customize the SDK's appearance to match your brand:

```swift
let customTheme = SDKColorScheme(
    // Primary Colors
    primaryColorHex: "#1E40AF",      // Your brand primary
    secondaryColorHex: "#F59E0B",    // Your brand secondary
    
    // Background
    backgroundColorHex: "#F9FAFB",   // Light background
    
    // Text Colors
    onBackgroundColorHex: "#111827", // Dark text
    
    // Buttons
    primaryButtonColorHex: "#1E40AF",
    primaryButtonTextColorHex: "#FFFFFF"
)

ArtiusIDSDK.shared.updateTheme(customTheme)
```

### **Image Overrides**

Replace SDK images with your own:

```swift
let imageOverrides = SDKImageOverrides(
    loadingStrategy: .assets,
    welcomeLogo: "your_logo",           // From Assets.xcassets
    welcomeBackground: "your_background",
    customOverrides: [
        "success_icon": "custom_success",
        "error_icon": "custom_error"
    ]
)

ArtiusIDSDK.shared.updateImageOverrides(imageOverrides)
```

### **Text Localization**

Override SDK text strings:

```swift
let customText = [
    "welcome_title": "Welcome to SecureBank",
    "welcome_subtitle": "Fast and secure identity verification",
    "verify_document_title": "Scan Your ID",
    "face_scan_title": "Face Verification"
]

ArtiusIDSDK.shared.updateLocalizations(customText, for: "en")
```

---

## 📱 Sample Application

A complete reference implementation is included in the `sample-app/` directory, demonstrating:

- ✅ **5 Complete Theme Examples** (Corporate, Banking, FinTech, etc.)
- ✅ **Image Override Strategies** (Asset-based, URL-based, Hybrid)
- ✅ **Multi-Language Support** (English, Spanish, French)
- ✅ **Environment Switching** (Sandbox, UAT, Production)
- ✅ **FCM Integration** for approval notifications
- ✅ **Biometric Authentication** (Face ID/Touch ID)

### **Running the Sample App**

1. Open `artiusid-sdk-ios.xcodeproj`
2. Select the **ArtiusIDSampleApp** scheme
3. Choose a simulator or device
4. Click **Run** (⌘R)

See `sample-app/README.md` for detailed documentation.

---

## 🔐 Features

### **Identity Verification**
- Document scanning (Driver's License, State ID, Passport)
- Face verification with liveness detection
- NFC passport chip reading
- Background checks and identity validation

### **Biometric Authentication**
- Face ID / Touch ID integration
- Secure approval workflows
- Multi-factor authentication support

### **Firebase Cloud Messaging**
- Push notification support for approvals
- Real-time status updates
- Secure notification handling

### **Security**
- End-to-end encryption
- Certificate pinning
- Mutual TLS (mTLS) authentication
- Keychain storage for sensitive data

---

## 🌍 Environments

The SDK supports three environments:

| Environment | Purpose | URL |
|-------------|---------|-----|
| **Sandbox** | Development & Testing | `sandbox.mobile.artiusid.dev` |
| **UAT** | User Acceptance Testing | `service-mobile.stage.artiusid.dev` |
| **Production** | Live Production | `service-mobile.artiusid.dev` |

```swift
// Development
ArtiusIDSDK.shared.initialize(
    clientId: YOUR_CLIENT_ID,
    clientGroupId: YOUR_CLIENT_GROUP_ID,
    environment: .sandbox
)

// Production
ArtiusIDSDK.shared.initialize(
    clientId: YOUR_CLIENT_ID,
    clientGroupId: YOUR_CLIENT_GROUP_ID,
    environment: .production
)
```

---

## 📋 Requirements

### **Minimum Requirements**
- iOS 14.0+
- Xcode 15.0+
- Swift 5.9+

### **Required Capabilities**
- Camera access (for document/face scanning)
- NFC capability (for passport reading)
- Face ID/Touch ID (for biometric auth)
- Network access (for API communication)

### **Optional**
- Firebase Cloud Messaging (for push notifications)

---

## 🔧 Configuration

### **Client Credentials**

Contact ArtiusID support to obtain:
- `clientId` - Your unique client identifier
- `clientGroupId` - Your organization group ID
- Environment-specific API keys

### **Firebase Setup (Optional)**

For push notification support:

1. Add `GoogleService-Info.plist` to your project
2. Initialize Firebase in your app delegate
3. Configure FCM in the SDK

```swift
import FirebaseCore
import FirebaseMessaging

func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}
```

---

## 🐛 Troubleshooting

### **Common Issues**

#### **"Module 'ArtiusIDSDK' not found"**
- Ensure package is added to your target
- Clean build folder: Product → Clean Build Folder (⇧⌘K)
- Reset package cache: File → Packages → Reset Package Caches

#### **Camera/NFC Permission Denied**
- Check Info.plist has required usage descriptions
- Verify app has proper entitlements
- Request permissions at appropriate time

#### **Certificate Errors**
- Ensure device has internet connection
- Check environment configuration
- Verify client credentials are correct

#### **Build Errors**
- Minimum iOS deployment target: 14.0
- Ensure Xcode 15.0+ is installed
- Check Swift version: 5.9+

---

## 📚 Additional Resources

### **Documentation**
- API Reference: See `sample-app/` for code examples
- Integration Guide: `sample-app/INTEGRATION-GUIDE.md`
- Theme Customization: `sample-app/Theme/SampleAppThemes.swift`

### **Sample Implementations**
- Basic verification flow: `sample-app/Views/SampleAppView.swift`
- Custom theming: `sample-app/Theme/`
- Image overrides: `sample-app/Config/SampleImageOverrides.swift`
- Localization: `sample-app/Config/SampleLocalizations.swift`

---

## 💬 Support

### **Technical Support**
- **Email:** support@artiusid.dev
- **Response Time:** 24-48 hours for standard inquiries

### **Before Contacting Support**
Please have ready:
- SDK version number
- iOS version and device model
- Xcode version
- Error messages or logs
- Steps to reproduce the issue

### **Reporting Issues**
Include:
1. Detailed description of the problem
2. Expected vs actual behavior
3. Code snippet demonstrating the issue
4. Console logs (if applicable)
5. Screenshots or screen recordings

---

## 📄 License

Proprietary software. All rights reserved by ArtiusID, Inc.

Usage requires a valid license agreement. Contact sales@artiusid.dev for licensing information.

---

## 🔄 Version History

### Latest Release
See [GitHub Releases](https://github.com/artius-iD/sdk/releases) for version history and changelogs.

### Checking SDK Version

```swift
let version = ArtiusIDSDK.version
print("SDK Version: \(version)")
```

---

## ⚡ Quick Integration Checklist

- [ ] Add SDK package to Xcode project
- [ ] Configure Info.plist permissions (Camera, Face ID, NFC)
- [ ] Initialize SDK with credentials
- [ ] Test verification flow in Sandbox
- [ ] Customize theme (optional)
- [ ] Add localization (optional)
- [ ] Configure Firebase for notifications (optional)
- [ ] Test on physical device
- [ ] Migrate to Production environment

---

**Need Help?** Email support@artiusid.dev or check the `sample-app/` directory for working examples.

**Ready for Production?** Contact our team to obtain production credentials and complete your integration review.

