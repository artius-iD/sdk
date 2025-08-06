# ArtiusID iOS SDK

**Professional identity verification and document scanning SDK for iOS applications.**

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/artiusID/sdk.git", from: "1.0.0")
]
```

### Xcode Integration

1. File → Add Package Dependencies
2. Enter URL: `https://github.com/artiusID/sdk.git`
3. Select the latest version or specify a minimum version

## Platform Requirements

### Runtime Target
- **iPhone and iPad devices exclusively** 📱
- **iOS 13.0+** minimum deployment target
- **Production use**: iPhone and iPad only

### Development Requirements
- **macOS 10.15+** required for build compatibility
- **Xcode 12.0+** recommended
- **Swift 5.3+** supported

## Why macOS in Package.swift?

The Package.swift declares macOS 10.15+ support **solely for development build compatibility**:

```swift
platforms: [
    .iOS(.v13),      // ✅ Runtime target: iPhone & iPad
    .macOS(.v10_15)  // 🛠️ Build-only: Required by OpenSSL dependency
]
```

### Technical Explanation

1. **XCFramework Dependency**: ArtiusID SDK was built with OpenSSL integration
2. **OpenSSL Package**: krzyzanowskim/OpenSSL requires macOS 10.15+ for Swift Package Manager
3. **Build Compatibility**: macOS platform enables successful dependency resolution
4. **Runtime Reality**: Code uses UIKit directly - iPhone/iPad execution only

## Integration

Your client app should target iPhone and iPad exclusively:

```swift
// Your client app's Package.swift or project settings
platforms: [.iOS(.v13)]  // iPhone & iPad only
```

The SDK's macOS declaration won't affect your app's deployment targets.

## Dependencies

- **OpenSSL 3.3.2000+**: Required by XCFramework binary for cryptographic operations
- **Firebase iOS SDK 11.9.0+**: Optional, conditionally imported when available
  - FirebaseCore: Automatic configuration detection
  - FirebaseMessaging: Push notification support

## Features

- 📱 **Document Scanning**: Passport, driver's license, and ID verification
- 🔐 **Biometric Authentication**: Face ID and Touch ID integration  
- 🎯 **Identity Verification**: Real-time document validation with ML models
- 🔥 **Firebase Integration**: Optional push notifications and analytics
- 📐 **SwiftUI & UIKit**: Native iOS component support
- 🌐 **Network Security**: OpenSSL-powered secure communications

## Usage

### Basic Setup

```swift
import ArtiusIDSDK

// Configure the SDK (typically in AppDelegate)
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Initialize ArtiusID SDK
    ArtiusIDSDKWrapper.shared.configure()
    
    return true
}
```

### With Firebase Integration

```swift
import ArtiusIDSDK
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase first
        FirebaseApp.configure()
        
        // Initialize ArtiusID SDK (will detect Firebase automatically)
        ArtiusIDSDKWrapper.shared.configure()
        
        // Set up Firebase Messaging
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Handle FCM token updates
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            ArtiusIDSDKWrapper.shared.updateFCMToken(token)
        }
    }
}
```

### SDK Information

```swift
// Get SDK version and info
let info = ArtiusIDSDKWrapper.shared.getSDKInfo()
print("SDK Version: \(info["sdkVersion"] ?? "Unknown")")
print("Platform: \(info["platform"] ?? "Unknown")")

// Print detailed info
printArtiusIDSDKInfo()
```

## Version Information

To get the current SDK version and release information:

- **In Code**: Use `artiusIDSDKVersion()` function or `ArtiusIDSDKInfo.version`
- **GitHub Releases**: Check [releases page](https://github.com/artiusID/sdk/releases) for latest version
- **Package.swift**: Binary target URL contains the version number
- **Build Info**: Use `ArtiusIDSDKInfo.printInfo()` for complete build details

## Binary Information

- **Framework Size**: ~43MB (30MB device slice, 38MB simulator slice)
- **Production Size**: ~30MB (device-only deployment)
- **ML Model Size**: 639KB (ICAO document verification)
- **Asset Size**: ~22MB (UI components and animations)
- **Checksum**: Available in Package.swift and GitHub releases

## Support & Resources

- **GitHub Repository**: [https://github.com/artiusID/sdk](https://github.com/artiusID/sdk)
- **Issues & Bug Reports**: [GitHub Issues](https://github.com/artiusID/sdk/issues)
- **Latest Release**: [GitHub Releases](https://github.com/artiusID/sdk/releases)
- **Documentation**: This README and inline code documentation

---

**Summary**: This SDK runs exclusively on iPhone and iPad devices. The macOS platform requirement in Package.swift exists purely for build system compatibility with the OpenSSL dependency.
