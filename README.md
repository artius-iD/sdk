# ArtiusID iOS SDK

A professional identity verification and document scanning SDK for iOS applications.  
This SDK provides a Swift wrapper (`ArtiusIDSDKWrapper`) for a binary framework, with optional Firebase integration and secure FCM token management.

## Project Structure

```
.
├── Sources/                    # Public SDK interface
│   ├── ArtiusIDSDKWrapper.swift    # Main SDK wrapper
│   └── SDKResourceBundle.swift     # Resource management
├── Constants/                 # SDK constants (internal)
├── Enums/                    # Enumerations (internal)
├── Extensions/               # Swift extensions (internal)
├── Helper/                  # Helper utilities (internal)
├── Models/                  # Data models (internal)
├── Services/                # Service layer (internal)
├── Utilities/               # Utility functions (internal)
├── Views/                   # UI components (internal)
├── Tests/                    # Test suite
│   ├── ArtiusIDSDKTests/    # Unit tests
│   └── ArtiusIDSDKUITests/  # UI tests
├── Resources/               # Project resources
├── scripts/                # Build and deployment scripts
│   ├── build-framework.sh  # Build universal binary framework
│   ├── cleanup-repository.sh # Clean temporary files
│   ├── publish-github.sh   # Publish SDK release
│   └── publish-only.sh     # Update existing release
└── Package.swift           # Swift package manifest
```

## Features

- Document verification and authentication
- Face mesh analysis and biometric verification
- Certificate-based security
- Client-controlled Firebase integration for notifications
- SwiftUI and UIKit support
- Secure FCM token storage via Keychain
- Universal binary (device + simulator)

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.3+
- macOS 10.15+ (for build compatibility with OpenSSL)

## Installation

### Swift Package Manager (Recommended)

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/artiusID/sdk.git", from: "1.0.16")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/artiusID/sdk.git`
3. Select version and add to your target

### Manual Installation

1. Download the latest `artiusid_sdk_ios.xcframework.zip` from [GitHub Releases](https://github.com/artiusID/sdk/releases)
2. Extract and drag `artiusid_sdk_ios.xcframework` into your Xcode project
3. Add Firebase dependencies to your project (FirebaseCore, FirebaseMessaging) if you want push notifications
4. OpenSSL is included automatically

## Usage

### Import the SDK

In your client Swift files, import the library:

```swift
import artiusid_sdk_ios
```

This exposes the `ArtiusIDSDKWrapper` API.

### Basic Setup

```swift
import artiusid_sdk_ios

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize ArtiusID SDK
    ArtiusIDSDKWrapper.shared.configure(environment: .production)
    return true
}
```

### With Firebase Integration

```swift
import artiusid_sdk_ios
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        ArtiusIDSDKWrapper.shared.configure(environment: .production)
        Messaging.messaging().delegate = self
        return true
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            ArtiusIDSDKWrapper.shared.updateFCMToken(token)
        }
    }
}
```

### FCM Token Management

```swift
// Update FCM token
ArtiusIDSDKWrapper.shared.updateFCMToken(token)

// Get current FCM token
let token = ArtiusIDSDKWrapper.shared.getCurrentFCMToken()

// Check if SDK is ready for verification
if ArtiusIDSDKWrapper.shared.isReadyForVerification() {
    // Ready to use SDK features
}
```

### Get SDK Info

```swift
let info = ArtiusIDSDKWrapper.shared.getSDKInfo()
print("SDK Version: 1.0.96
print("Platform: \(info["platform"] ?? "Unknown")")

printArtiusIDSDKInfo()
```

## API Reference

### Core Types

```swift
public enum Environments {
    case development
    case staging
    case production
}

public enum LogLevel {
    case debug
    case info
    case warning
    case error
}
```

### Main Wrapper

```swift
public class ArtiusIDSDKWrapper {
    public static let shared: ArtiusIDSDKWrapper
    public func configure(environment: Environments? = nil, logLevel: LogLevel = .info)
    public func updateFCMToken(_ token: String)
    public func getCurrentFCMToken() -> String?
    public func getSDKInfo() -> [String: Any]
    public func isReadyForVerification() -> Bool
}
```

### Convenience API

```swift
public typealias ArtiusID = ArtiusIDSDKWrapper

public func configureArtiusIDSDK(environment: Environments? = nil, logLevel: LogLevel = .info)
public func artiusIDSDKVersion() -> String
public func printArtiusIDSDKInfo()
```

## Firebase Integration

- The SDK will auto-detect Firebase if present.
- You must configure Firebase in your app if you want push notifications.
- Pass FCM tokens to the SDK using `updateFCMToken`.

## Troubleshooting

- Ensure all dependencies (Firebase, OpenSSL) are properly added.
- Verify Firebase is configured before SDK initialization if using notifications.
- Clean build artifacts if you see SwiftPM errors:
  ```bash
  ./scripts/cleanup-repository.sh
  ```

## Support

- Email: support@artiusid.com
- Documentation: [docs.artiusid.com](https://docs.artiusid.com)
- Issues: [GitHub Issues](https://github.com/artiusID/sdk/issues)

## License

This SDK is proprietary software. See the license agreement for terms of use.
