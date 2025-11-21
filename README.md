# ArtiusID iOS SDK - Client Implementation Guide

**SDK Version:** v2.0.16  
**Date:** November 21, 2025  
**Target Audience:** Client Application Developers  
**Status:** ✅ Production Ready

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Configuration](#configuration)
5. [Verification Flow](#verification-flow)
6. [Authentication Flow](#authentication-flow)
7. [Result Handling](#result-handling)
8. [Error Handling & Document Recapture](#error-handling--document-recapture)
9. [Okta ID Integration](#okta-id-integration)
10. [Theming & Customization](#theming--customization)
11. [Best Practices](#best-practices)
12. [Troubleshooting](#troubleshooting)
13. [API Reference](#api-reference)

---

## 📖 Overview

The ArtiusID iOS SDK provides a complete identity verification and authentication solution for iOS applications. This guide covers all features available in v2.0.15.

### Key Features

- ✅ **Identity Verification** - Face scan + Government ID verification
- ✅ **Biometric Authentication** - Face-based authentication for returning users
- ✅ **Document Recapture** - Automatic retry for recoverable document errors
- ✅ **Okta ID Integration** - Optional Okta ID collection during verification
- ✅ **Mutual TLS** - Secure API communication with client certificates
- ✅ **Firebase Cloud Messaging** - Push notification support
- ✅ **Enhanced Theming** - Complete UI customization
- ✅ **Localization** - Multi-language support

### Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Firebase (client app manages Firebase configuration)

---

## 🚀 Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Packages**
2. Enter the repository URL:
   ```
   https://github.com/artius-iD/sdk.git
   ```
3. Select version `2.0.16` or "Up to Next Major Version" from `2.0.16`
4. Click **Add Package**

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/artius-iD/sdk.git", from: "2.0.16")
]
```

---

## ⚡ Quick Start

### 1. Import the SDK

```swift
import artiusid_sdk_ios
```

### 2. Configure the SDK

In your app initialization (AppDelegate or SwiftUI App struct):

```swift
import SwiftUI
import artiusid_sdk_ios

@main
struct YourApp: App {
    init() {
        configureSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureSDK() {
        ArtiusIDSDKWrapper.shared.configure(
            environment: .sandbox,
            baseURL: "https://sandbox.mobile.artiusid.dev",
            registrationDomain: "sandbox.registration.artiusid.dev",
            includeOktaIDInVerificationPayload: true,  // Optional: Enable Okta ID
            logLevel: .debug
        )
        
        print("✅ ArtiusID SDK v\(ArtiusIDSDKInfo.version) configured")
    }
}
```

### 3. Start Verification

```swift
import SwiftUI
import ArtiusIDSDK

struct ContentView: View {
    @State private var showVerification = false
    
    var body: some View {
        Button("Start Verification") {
            showVerification = true
        }
        .fullScreenCover(isPresented: $showVerification) {
            ArtiusIDVerificationView(
                configuration: ArtiusIDVerificationView.Configuration(
                    clientId: YOUR_CLIENT_ID,
                    environment: .sandbox
                ),
                onCompletion: { result in
                    showVerification = false
                    handleResult(result)
                },
                onCancel: {
                    showVerification = false
                }
            )
        }
    }
    
    func handleResult(_ result: VerificationResult) {
        if result.isSuccessful {
            print("✅ Verified: \(result.fullName ?? "Unknown")")
        } else {
            print("❌ Failed: \(result.errorMessage ?? "Unknown")")
        }
    }
}
```

---

## ⚙️ Configuration

### Environment Configuration

The SDK supports multiple environments:

| Environment | Base URL | Registration Domain | Use Case |
|------------|----------|---------------------|----------|
| **Sandbox** | `https://sandbox.mobile.artiusid.dev` | `sandbox.registration.artiusid.dev` | Development & Testing |
| **Development** | `https://service-mobile.dev.artiusid.dev` | `service-registration.dev.artiusid.dev` | Internal Development |
| **Staging** | `https://service-mobile.stage.artiusid.dev` | `service-registration.stage.artiusid.dev` | Pre-production UAT |
| **Production** | `https://service-mobile.artiusid.dev` | `service-registration.artiusid.dev` | Live Production |

### Configuration Parameters

```swift
ArtiusIDSDKWrapper.shared.configure(
    environment: Environments,              // Required: .sandbox, .development, .staging, .production
    baseURL: String,                        // Required: Base URL for mobile services
    registrationDomain: String,             // Required: Domain for certificate registration
    includeOktaIDInVerificationPayload: Bool = true,  // Optional: Enable Okta ID collection
    logLevel: LogLevel = .info              // Optional: .debug, .info, .warning, .error
)
```

### Configuration Examples

#### Development Configuration

```swift
#if DEBUG
ArtiusIDSDKWrapper.shared.configure(
    environment: .sandbox,
    baseURL: "https://sandbox.mobile.artiusid.dev",
    registrationDomain: "sandbox.registration.artiusid.dev",
    includeOktaIDInVerificationPayload: true,
    logLevel: .debug
)
#else
ArtiusIDSDKWrapper.shared.configure(
    environment: .production,
    baseURL: "https://service-mobile.artiusid.dev",
    registrationDomain: "service-registration.artiusid.dev",
    includeOktaIDInVerificationPayload: true,
    logLevel: .warning
)
#endif
```

#### Dynamic Environment Switching

```swift
class AppConfiguration {
    enum Environment {
        case sandbox, staging, production
        
        var sdkConfig: (env: Environments, baseURL: String, regDomain: String) {
            switch self {
            case .sandbox:
                return (.sandbox, 
                       "https://sandbox.mobile.artiusid.dev",
                       "sandbox.registration.artiusid.dev")
            case .staging:
                return (.staging, 
                       "https://service-mobile.stage.artiusid.dev",
                       "service-registration.stage.artiusid.dev")
            case .production:
                return (.production, 
                       "https://service-mobile.artiusid.dev",
                       "service-registration.artiusid.dev")
            }
        }
    }
    
    static func configure(for environment: Environment) {
        let config = environment.sdkConfig
        ArtiusIDSDKWrapper.shared.configure(
            environment: config.env,
            baseURL: config.baseURL,
            registrationDomain: config.regDomain,
            logLevel: .debug
        )
    }
}

// Usage:
AppConfiguration.configure(for: .sandbox)
```

---

## 🎯 Verification Flow

### Basic Verification

```swift
import SwiftUI
import ArtiusIDSDK

struct VerificationView: View {
    @State private var showVerification = false
    @State private var showResult = false
    @State private var resultMessage = ""
    
    var body: some View {
        VStack {
            Button("Start Verification") {
                showVerification = true
            }
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $showVerification) {
            ArtiusIDVerificationView(
                configuration: createConfiguration(),
                onCompletion: { result in
                    showVerification = false
                    handleVerificationResult(result)
                },
                onCancel: {
                    showVerification = false
                    print("User cancelled verification")
                }
            )
        }
        .alert("Verification Result", isPresented: $showResult) {
            Button("OK") { }
        } message: {
            Text(resultMessage)
        }
    }
    
    func createConfiguration() -> ArtiusIDVerificationView.Configuration {
        return ArtiusIDVerificationView.Configuration(
            clientId: YOUR_CLIENT_ID,
            clientGroupId: YOUR_CLIENT_GROUP_ID,  // Optional
            environment: .sandbox
        )
    }
    
    func handleVerificationResult(_ result: VerificationResult) {
        // Step 1: Check for document recapture (v2.0.6+)
        if result.requiresRecapture, let recaptureType = result.recaptureType {
            resultMessage = """
            Document recapture required: \(recaptureType.title)
            
            \(recaptureType.message)
            
            You can restart verification to try again.
            """
            showResult = true
            return
        }
        
        // Step 2: Handle success or failure
        if result.isSuccessful {
            resultMessage = """
            ✅ Verification Successful!
            
            Name: \(result.fullName ?? "N/A")
            Account: \(result.accountNumber ?? "N/A")
            Score: \(Int(result.verificationScore * 100))%
            """
            
            // Include Okta ID if collected
            if let oktaId = result.oktaId {
                resultMessage += "\nOkta ID: \(oktaId)"
            }
        } else {
            resultMessage = """
            ❌ Verification Failed
            
            \(result.errorMessage ?? "Unknown error")
            """
        }
        showResult = true
    }
}
```

### UIKit Integration

```swift
import UIKit
import SwiftUI
import ArtiusIDSDK

class ViewController: UIViewController {
    
    func startVerification() {
        let configuration = ArtiusIDVerificationView.Configuration(
            clientId: YOUR_CLIENT_ID,
            environment: .sandbox
        )
        
        let verificationView = ArtiusIDVerificationView(
            configuration: configuration,
            onCompletion: { [weak self] result in
                self?.dismiss(animated: true) {
                    self?.handleVerificationResult(result)
                }
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true)
                print("User cancelled verification")
            }
        )
        
        let hostingController = UIHostingController(rootView: verificationView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    func handleVerificationResult(_ result: VerificationResult) {
        if result.requiresRecapture, let recaptureType = result.recaptureType {
            showAlert(
                title: "Document Recapture Required",
                message: "\(recaptureType.title)\n\n\(recaptureType.message)"
            )
            return
        }
        
        if result.isSuccessful {
            showAlert(
                title: "✅ Verification Successful",
                message: "Name: \(result.fullName ?? "N/A")\nAccount: \(result.accountNumber ?? "N/A")"
            )
        } else {
            showAlert(
                title: "❌ Verification Failed",
                message: result.errorMessage ?? "Unknown error"
            )
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

---

## 🔐 Authentication Flow

### Basic Authentication

```swift
import SwiftUI
import ArtiusIDSDK

struct AuthenticationView: View {
    @State private var showAuthentication = false
    @State private var authResult: String = ""
    
    var body: some View {
        VStack {
            Button("Authenticate") {
                showAuthentication = true
            }
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $showAuthentication) {
            ArtiusIDAuthenticationView(
                clientId: YOUR_CLIENT_ID,
                accountNumber: "USER_ACCOUNT_NUMBER",  // From previous verification
                onCompletion: { result in
                    showAuthentication = false
                    handleAuthResult(result)
                },
                onCancel: {
                    showAuthentication = false
                }
            )
        }
    }
    
    func handleAuthResult(_ result: AuthenticationResult) {
        if result.isSuccessful {
            print("✅ Authentication successful!")
            print("   Account: \(result.accountNumber ?? "N/A")")
            print("   Score: \(result.authenticationScore)")
        } else {
            print("❌ Authentication failed: \(result.errorMessage ?? "Unknown")")
        }
    }
}
```

---

## 📊 Result Handling

### VerificationResult Structure

```swift
public struct VerificationResult {
    // Success indicators
    public let isSuccessful: Bool
    public let verificationScore: Double
    
    // User information
    public let accountNumber: String?
    public let fullName: String?
    public let firstName: String?
    public let lastName: String?
    public let middleName: String?
    public let dateOfBirth: String?
    
    // Document information
    public let documentNumber: String?
    public let documentType: String?
    public let expirationDate: String?
    public let issueDate: String?
    
    // Address information
    public let address: String?
    public let city: String?
    public let state: String?
    public let zipCode: String?
    public let country: String?
    
    // Error handling
    public let errorMessage: String?
    public let errorCode: Int?
    
    // Document recapture (v2.0.6+)
    public let requiresRecapture: Bool
    public let recaptureType: DocumentRecaptureType?
    
    // Okta ID (v2.0.11+)
    public let oktaId: String?
}
```

### AuthenticationResult Structure

```swift
public struct AuthenticationResult {
    public let isSuccessful: Bool
    public let authenticationScore: Double
    public let accountNumber: String?
    public let errorMessage: String?
    public let errorCode: Int?
}
```

### Complete Result Handler

```swift
func handleVerificationResult(_ result: VerificationResult) {
    print("========================================")
    print("VERIFICATION RESULT")
    print("========================================")
    
    // STEP 1: Check for document recapture (v2.0.6+)
    if result.requiresRecapture, let recaptureType = result.recaptureType {
        print("⚠️ Document Recapture Required")
        print("   Type: \(recaptureType.title)")
        print("   Message: \(recaptureType.message)")
        print("   Action: \(recaptureType.actionText)")
        
        // User cancelled the recapture - they can restart to try again
        showRecaptureAlert(recaptureType)
        return
    }
    
    // STEP 2: Handle success
    if result.isSuccessful {
        print("✅ SUCCESS")
        print("   Account Number: \(result.accountNumber ?? "N/A")")
        print("   Full Name: \(result.fullName ?? "N/A")")
        print("   DOB: \(result.dateOfBirth ?? "N/A")")
        print("   Document: \(result.documentType ?? "N/A") - \(result.documentNumber ?? "N/A")")
        print("   Address: \(result.address ?? "N/A"), \(result.city ?? "N/A"), \(result.state ?? "N/A")")
        print("   Score: \(Int(result.verificationScore * 100))%")
        
        // Check for Okta ID (v2.0.11+)
        if let oktaId = result.oktaId {
            print("   Okta ID: \(oktaId)")
            linkOktaAccount(oktaId, accountNumber: result.accountNumber)
        }
        
        // Store account number for future authentication
        saveAccountNumber(result.accountNumber)
        
        showSuccessAlert(result)
    }
    // STEP 3: Handle failure
    else {
        print("❌ FAILED")
        print("   Error: \(result.errorMessage ?? "Unknown error")")
        print("   Code: \(result.errorCode ?? 0)")
        
        showFailureAlert(result)
    }
    
    print("========================================")
}
```

---

## 🔄 Error Handling & Document Recapture

### Overview

Starting in v2.0.6, error codes **600-604** trigger automatic document recapture instead of permanent failure. This allows users to retry without restarting the entire verification flow.

### Recapture-able Error Codes

| Code | Error Type | Description | Retry Action |
|------|-----------|-------------|--------------|
| **600** | OCR Error | Document text unclear | Recapture document front |
| **601** | MRZ/Barcode Error | Passport MRZ or ID barcode unclear | Recapture document (passport or ID back) |
| **602** | Back Error | State ID back unclear | Recapture ID back |
| **603** | Quality Error | Poor image quality | Retake photo with better lighting |
| **604** | NFC Timeout | Chip read timeout | Retry NFC scan or continue |

### Permanent Failures (No Recapture)

| Code | Error Type | Description |
|------|-----------|-------------|
| **605** | Document Validation Failed | Document failed security checks |
| **400** | General Error | Generic API error |
| **500** | Server Error | Internal server error |

### Implementation

```swift
func handleVerificationResult(_ result: VerificationResult) {
    // ✅ ALWAYS check requiresRecapture FIRST
    if result.requiresRecapture, let recaptureType = result.recaptureType {
        // This is a recoverable error (600-604)
        // SDK already showed the DocumentRecaptureNotificationView
        // User either:
        // 1. Successfully retried → flow continues (you won't get this result)
        // 2. Cancelled → SDK dismissed, you get this result
        
        print("⚠️ Recapture Required:")
        print("   Type: \(recaptureType.title)")
        print("   Message: \(recaptureType.message)")
        
        showAlert(
            title: recaptureType.title,
            message: "\(recaptureType.message)\n\nYou can restart verification to try again.",
            actions: [
                ("Restart", { self.restartVerification() }),
                ("Cancel", nil)
            ]
        )
        return
    }
    
    // Normal success/failure handling...
    if result.isSuccessful {
        handleSuccess(result)
    } else {
        handlePermanentFailure(result)
    }
}
```

### DocumentRecaptureType

```swift
public enum DocumentRecaptureType {
    case passportMRZError       // Error 601 - Passport MRZ unclear
    case passportOCRError       // Error 600 - Passport text unclear
    case stateIdFrontError      // Error 600 - State ID front unclear
    case stateIdBackError       // Error 602 - State ID back unclear
    case stateIdBarcodeError    // Error 601 - State ID barcode unclear
    case imageQualityError      // Error 603 - Poor image quality
    case nfcTimeoutError        // Error 604 - NFC chip read timeout
    case generalAPIError        // Other API errors
    
    public var title: String {
        // User-friendly title like "Government Passport MRZ Issue"
    }
    
    public var message: String {
        // Detailed explanation and instructions for the user
    }
    
    public var actionText: String {
        // Button text like "Recapture Government Passport"
    }
}
```

### User Experience

When a recapture-able error occurs (600-604):

1. SDK automatically shows `DocumentRecaptureNotificationView`
2. User sees error-specific instructions
3. User can tap "Recapture" button to retry immediately
4. SDK navigates back to the appropriate scan screen
5. Previous scan data is cleared
6. User retakes photo
7. Verification continues

If user taps "Cancel" instead:
- SDK dismisses
- Your app receives result with `requiresRecapture = true`
- You can offer to restart verification

---

## 🆔 Okta ID Integration

### Overview

v2.0.11 introduces optional Okta ID collection during the verification flow. This allows you to link ArtiusID verification with Okta accounts.

### Enabling Okta ID Collection

```swift
// Enable Okta ID collection (default: true)
ArtiusIDSDKWrapper.shared.configure(
    environment: .sandbox,
    baseURL: "https://sandbox.mobile.artiusid.dev",
    registrationDomain: "sandbox.registration.artiusid.dev",
    includeOktaIDInVerificationPayload: true,  // ✅ Enable Okta ID
    logLevel: .debug
)
```

### Disabling Okta ID Collection

```swift
// Disable Okta ID collection
ArtiusIDSDKWrapper.shared.configure(
    environment: .production,
    baseURL: "https://service-mobile.artiusid.dev",
    registrationDomain: "service-registration.artiusid.dev",
    includeOktaIDInVerificationPayload: false,  // ❌ Disable Okta ID
    logLevel: .warning
)
```

### Verification Flow with Okta ID

When enabled, the flow includes an Okta ID collection step:

```
1. Face Scan (Live Selfie)
      ↓
2. Document Scan (Passport or State ID)
      ↓
3. Okta ID Entry (if enabled)
      ↓
4. Processing & Verification
      ↓
5. Results
```

### Handling Okta ID in Results

```swift
func handleVerificationResult(_ result: VerificationResult) {
    if result.isSuccessful {
        print("✅ Verification successful!")
        
        // Check for Okta ID (v2.0.11+)
        if let oktaId = result.oktaId, !oktaId.isEmpty {
            print("   Okta ID: \(oktaId)")
            
            // Link Okta account with ArtiusID verification
            linkOktaAccount(
                oktaId: oktaId,
                accountNumber: result.accountNumber,
                fullName: result.fullName
            )
        } else {
            print("   Okta ID: Not collected")
        }
    }
}

func linkOktaAccount(oktaId: String, accountNumber: String?, fullName: String?) {
    // TODO: Implement your Okta account linking logic
    print("🔗 Linking Okta account:")
    print("   Okta ID: \(oktaId)")
    print("   ArtiusID Account: \(accountNumber ?? "N/A")")
    print("   Name: \(fullName ?? "N/A")")
    
    // Example: Send to your backend
    // POST /api/link-okta
    // Body: { "oktaId": "...", "artiusAccountNumber": "..." }
}
```

### Dynamic Okta ID Toggle

For apps that allow users to enable/disable Okta ID collection:

```swift
class AppSettings: ObservableObject {
    @Published var oktaIdEnabled: Bool = true {
        didSet {
            reconfigureSDK()
        }
    }
    
    func reconfigureSDK() {
        ArtiusIDSDKWrapper.shared.configure(
            environment: .sandbox,
            baseURL: "https://sandbox.mobile.artiusid.dev",
            registrationDomain: "sandbox.registration.artiusid.dev",
            includeOktaIDInVerificationPayload: oktaIdEnabled,
            logLevel: .debug
        )
        print("✅ Okta ID collection: \(oktaIdEnabled ? "enabled" : "disabled")")
    }
}

// Usage in UI
struct SettingsView: View {
    @StateObject var settings = AppSettings()
    
    var body: some View {
        Form {
            Section("Okta Integration") {
                Toggle("Collect Okta ID", isOn: $settings.oktaIdEnabled)
                    .onChange(of: settings.oktaIdEnabled) { _ in
                        // SDK reconfigures automatically via didSet
                    }
            }
        }
    }
}
```

---

## 🎨 Theming & Customization

### Basic Theme Configuration

```swift
import ArtiusIDSDK

let theme = EnhancedSDKThemeConfiguration(
    colorScheme: SDKColorScheme(
        primaryColorHex: "#007AFF",
        secondaryColorHex: "#FF9500",
        backgroundColorHex: "#FFFFFF",
        textColorHex: "#000000",
        primaryButtonColorHex: "#007AFF",
        secondaryButtonColorHex: "#8E8E93"
    ),
    typography: SDKTypography(
        titleFont: "System Bold",
        titleSize: 28,
        bodyFont: "System Regular",
        bodySize: 16,
        buttonFont: "System Semibold",
        buttonSize: 17
    ),
    brandName: "Your Company Name",
    brandLogoName: "your_logo"  // Asset name in your bundle
)

// Apply theme (typically in app initialization)
ThemeManager.shared.initialize(theme: theme, configuration: sdkConfig)
```

### Icon Theming (v2.0.11)

Face scan instruction icons now use the `secondaryColor` for better visual hierarchy:

```swift
let colorScheme = SDKColorScheme(
    primaryColorHex: "#007AFF",      // Primary buttons, main actions
    secondaryColorHex: "#FF9500",    // ✅ Face scan instruction icons
    backgroundColorHex: "#FFFFFF",
    textColorHex: "#000000"
)
```

### Image Overrides

Replace SDK images with your own:

```swift
let imageOverrides: [String: String] = [
    "face_scan_frame": "custom_face_frame",
    "document_frame": "custom_doc_frame",
    "success_icon": "custom_success",
    // ... more overrides
]

// Apply overrides
ImageOverrideManager.shared.setOverrides(imageOverrides)
```

### Localization

Override default strings:

```swift
let localizationOverrides: [String: String] = [
    "face_scan_title": "Take Your Selfie",
    "document_scan_title": "Scan Your ID",
    "okta_id_viewTitle": "Enter Company ID",
    // ... more overrides
]

LocalizationManager.shared.setOverrides(localizationOverrides)
```

---

## ✅ Best Practices

### 1. Always Check Recapture First

```swift
// ✅ CORRECT ORDER
func handleVerificationResult(_ result: VerificationResult) {
    if result.requiresRecapture {
        handleRecapture(result)
    } else if result.isSuccessful {
        handleSuccess(result)
    } else {
        handleFailure(result)
    }
}

// ❌ WRONG ORDER
func handleVerificationResult(_ result: VerificationResult) {
    if result.isSuccessful {
        handleSuccess(result)
    } else {
        // This treats recapture as permanent failure!
        handleFailure(result)
    }
}
```

### 2. Store Account Numbers for Authentication

```swift
func handleVerificationResult(_ result: VerificationResult) {
    if result.isSuccessful, let accountNumber = result.accountNumber {
        // Store for future authentication
        UserDefaults.standard.set(accountNumber, forKey: "artiusid_account_number")
        
        // Or use Keychain for better security
        KeychainHelper.standard["artiusid_account"] = accountNumber
    }
}
```

### 3. Handle Okta ID Appropriately

```swift
func handleVerificationResult(_ result: VerificationResult) {
    if result.isSuccessful {
        // Only process Okta ID if it was actually collected
        if let oktaId = result.oktaId, !oktaId.isEmpty {
            linkOktaAccount(oktaId, accountNumber: result.accountNumber)
        }
    }
}
```

### 4. Use Environment-Specific Configuration

```swift
#if DEBUG
let environment = Environments.sandbox
let logLevel = LogLevel.debug
#else
let environment = Environments.production
let logLevel = LogLevel.warning
#endif

ArtiusIDSDKWrapper.shared.configure(
    environment: environment,
    baseURL: environment.baseURL,
    registrationDomain: environment.registrationDomain,
    logLevel: logLevel
)
```

### 5. Log Important Events

```swift
func handleVerificationResult(_ result: VerificationResult) {
    // Log verification outcome
    Analytics.log("verification_complete", parameters: [
        "success": result.isSuccessful,
        "requires_recapture": result.requiresRecapture,
        "has_okta_id": result.oktaId != nil,
        "score": result.verificationScore
    ])
    
    if result.requiresRecapture {
        Analytics.log("verification_recapture_required", parameters: [
            "type": result.recaptureType?.title ?? "unknown"
        ])
    }
}
```

### 6. Provide Clear Error Messages

```swift
func handleVerificationResult(_ result: VerificationResult) {
    if result.requiresRecapture, let recaptureType = result.recaptureType {
        showAlert(
            title: recaptureType.title,
            message: """
            \(recaptureType.message)
            
            This error is recoverable. You can restart verification to try again.
            
            Tips:
            • Ensure good lighting
            • Hold device steady
            • Keep document flat and fully visible
            """
        )
    } else if !result.isSuccessful {
        showAlert(
            title: "Verification Failed",
            message: """
            \(result.errorMessage ?? "Unable to verify identity")
            
            Please try again or contact support if the problem persists.
            """
        )
    }
}
```

---

## 🐛 Troubleshooting

### Issue: SDK not initializing

**Symptoms:** App crashes or SDK features don't work

**Solution:**
```swift
// Verify SDK is configured before use
print("SDK Version: \(ArtiusIDSDKInfo.version)")
print("Environment: \(ArtiusIDSDK.shared.environment)")
print("Base URL: \(ArtiusIDSDK.shared.baseURL)")

// Ensure configure() is called in app initialization
// BEFORE using any SDK views
```

### Issue: Error 601 not showing recapture screen

**Cause:** Not checking `requiresRecapture` field

**Solution:**
```swift
// Always check requiresRecapture FIRST
if result.requiresRecapture {
    // Handle recapture
} else if result.isSuccessful {
    // Handle success
} else {
    // Handle permanent failure
}
```

### Issue: Okta ID is nil even when enabled

**Causes:**
1. Feature disabled in configuration
2. User skipped Okta ID entry
3. Result not properly checked

**Solution:**
```swift
// Verify configuration
print("Okta ID Enabled: \(ArtiusIDSDK.shared.includeOktaIDInVerificationPayload)")

// Check result properly
if let oktaId = result.oktaId, !oktaId.isEmpty {
    print("Okta ID collected: \(oktaId)")
} else {
    print("Okta ID not collected")
    // This is normal if feature is disabled or user didn't provide it
}
```

### Issue: Certificate errors / mTLS failures

**Symptoms:** 
- Network requests fail with `-1206` (server requires client certificate)
- Error `-25300` (errSecItemNotFound) when loading private key
- Error `-999` (cancelled) with "No client identity available"

**Root Causes:**
- Certificate and private key not properly linked in keychain
- Environment mismatch between certificate and API call
- Old certificate format from previous SDK versions

**Solution (v2.0.15+):**
```swift
// The SDK now automatically handles certificate linkage using kSecAttrLabel
// If you experience issues, clear credentials and regenerate:

// 1. Clear all credentials for the environment
try? CertificateManager.shared.removeCertificate()
// This removes BOTH certificate and private key

// 2. Regenerate certificate on next verification/authentication
// Certificate will be automatically regenerated with proper linkage

// 3. Verify in logs:
// "✅ Certificate and private key stored successfully"
// "✅ Successfully found existing identity for environment"
// "🔐 mTLS READY - Client certificate loaded"
```

**Note:** v2.0.15 includes significant improvements to certificate management:
- Environment-specific certificate storage
- Proper SecIdentity formation via kSecAttrLabel linkage
- Comprehensive logging for troubleshooting
- Automatic certificate reload after generation

### Issue: Wrong environment URLs

**Solution:**
```swift
// Verify URLs after configuration
print("🔍 SDK Configuration:")
print("   Environment: \(ArtiusIDSDK.shared.environment)")
print("   Base URL: \(ArtiusIDSDK.shared.baseURL)")
print("   Expected: \(expectedBaseURL)")

// Make sure you're using the correct environment constants
```

### Debug Logging

Enable verbose logging to diagnose issues:

```swift
ArtiusIDSDKWrapper.shared.configure(
    environment: .sandbox,
    baseURL: "https://sandbox.mobile.artiusid.dev",
    registrationDomain: "sandbox.registration.artiusid.dev",
    logLevel: .debug  // ✅ Enable all logs
)

// Look for logs like:
// ✅ VerificationResponse: Detected recapture-able error 601
// 📋 DocumentRecaptureNotificationView: Screen appeared
// 🔄 ArtiusIDVerificationView: User tapped recapture button
```

---

## 📚 API Reference

### ArtiusIDSDKWrapper

Main SDK entry point.

```swift
public class ArtiusIDSDKWrapper {
    public static let shared: ArtiusIDSDKWrapper
    
    public func configure(
        environment: Environments,
        baseURL: String,
        registrationDomain: String,
        includeOktaIDInVerificationPayload: Bool = true,
        logLevel: LogLevel = .info
    )
    
    public func updateFCMToken(_ token: String)
}
```

### ArtiusIDSDKInfo

SDK version information.

```swift
public struct ArtiusIDSDKInfo {
    public static let version: String              // "2.0.15"
    public static let wrapperVersion: String       // "2.0.15"
    public static let build: String
    public static let architecture: String
    
    public static func printInfo()
}
```

### Environments

```swift
public enum Environments: String {
    case sandbox        // "sandbox"
    case development    // "development"
    case staging        // "staging"
    case production     // "production"
    case qa             // "qa"
    
    // Backward compatibility
    case Sandbox        // "sandbox-env"
    case Development    // "dev"
    case Staging        // "stage"
    case Production     // "prod"
    case QA             // "qa-env"
}
```

### LogLevel

```swift
public enum LogLevel {
    case debug      // All logs (verbose)
    case info       // Informational logs
    case warning    // Warning and error logs
    case error      // Error logs only
}
```

### ArtiusIDVerificationView

Main verification view.

```swift
public struct ArtiusIDVerificationView: View {
    public struct Configuration {
        public let clientId: Int
        public let clientGroupId: Int?
        public let environment: Environments
        
        public init(
            clientId: Int,
            clientGroupId: Int? = nil,
            environment: Environments
        )
    }
    
    public init(
        configuration: Configuration,
        onCompletion: @escaping (VerificationResult) -> Void,
        onCancel: @escaping () -> Void
    )
}
```

### ArtiusIDAuthenticationView

Biometric authentication view.

```swift
public struct ArtiusIDAuthenticationView: View {
    public init(
        clientId: Int,
        accountNumber: String,
        onCompletion: @escaping (AuthenticationResult) -> Void,
        onCancel: @escaping () -> Void
    )
}
```

### VerificationResult

```swift
public struct VerificationResult {
    public let isSuccessful: Bool
    public let verificationScore: Double
    public let accountNumber: String?
    public let fullName: String?
    public let errorMessage: String?
    public let errorCode: Int?
    public let requiresRecapture: Bool              // v2.0.6+
    public let recaptureType: DocumentRecaptureType? // v2.0.6+
    public let oktaId: String?                      // v2.0.11+
    // ... additional fields
}
```

### DocumentRecaptureType

```swift
public enum DocumentRecaptureType {
    case passportMRZError
    case passportOCRError
    case stateIdFrontError
    case stateIdBackError
    case stateIdBarcodeError
    case imageQualityError
    case nfcTimeoutError
    case generalAPIError
    
    public var title: String
    public var message: String
    public var actionText: String
}
```

---

## 📧 Support

### SDK Information

- **Version:** v2.0.15
- **Release Date:** November 19, 2025
- **Status:** ✅ Production Ready

### Resources

- **GitHub Repository:** https://github.com/artius-iD/sdk
- **GitLab Repository:** https://gitlab.com/artiusid1/mobile-sdk-ios
- **Documentation:** See repository README and guides
- **Sample App:** `/ArtiusIDSampleApp` in repository

### Contact

- **Email:** sdk-support@artiusid.com
- **Issues:** Create an issue on GitHub/GitLab

---

## 📝 Changelog

### v2.0.15 (November 19, 2025)

**Critical mTLS Certificate Management Improvements:**
- ✅ Fixed SecIdentity formation by properly linking certificate and private key using kSecAttrLabel
- ✅ Environment-specific certificate and private key storage
- ✅ Automatic certificate reload after generation for immediate mTLS availability
- ✅ Comprehensive logging for certificate generation, storage, and mTLS handshake
- ✅ Enhanced clearCredentials to remove all certificate formats (backward compatibility)

**UI/UX Improvements:**
- ✅ Updated NFC passport instruction text ("HOLD PHONE AGAINST PASSPORT" instead of "PASSPORT COVER")
- ✅ Fixed certificate status display on home screen refresh
- ✅ Authentication request flow styling improvements

**Technical Details:**
- Certificate and private key now share the same `kSecAttrLabel` for proper identity formation
- `TLSSessionManager` now tracks loaded environment to prevent mismatch errors
- `VerificationResponse` now forces certificate reload after generation
- All keychain operations use environment-specific keys for multi-environment support

### v2.0.11 (November 14, 2025)

- ✅ Added Okta ID integration with configurable flag
- ✅ Enhanced theming for face scan instruction icons
- ✅ Certificate loading improvements
- ✅ Various UI and stability improvements

### v2.0.6 (November 13, 2025)

- ✅ Added document recapture for errors 600-604
- ✅ Added `requiresRecapture` and `recaptureType` to VerificationResult
- ✅ Added DocumentRecaptureNotificationView
- ✅ Improved error handling and user experience

### v2.0.4 (November 12, 2025)

- ✅ Added explicit base URL configuration
- ✅ Removed automatic URL construction
- ✅ Added `baseURL` and `registrationDomain` parameters

---

**Thank you for using ArtiusID! 🙏**

For additional help, please refer to the sample app or contact our support team.

*Last Updated: November 19, 2025*

