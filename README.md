# Artius.iD iOS SDK

Identity verification, biometric authentication and session binding for iOS apps, distributed as a binary Swift package.

| | |
|---|---|
| **Latest release** | [3.1.3](https://github.com/artius-iD/sdk/releases/tag/v3.1.3) (September 22, 2026) |
| **Platform** | iOS 18.2 or later (iPhone and iPad) |
| **Toolchain** | Xcode 26.6 or later. The framework is built with Swift 6.3 in Swift 5 language mode. |
| **Distribution** | Swift Package Manager |
| **Android SDK** | [artius-iD/artiusid_sdk_android](https://github.com/artius-iD/artiusid_sdk_android) |

## Features

- **Enrollment.** Guided face capture and government ID capture (photo ID or passport, including the passport chip over NFC). When a document image can't be read, the SDK walks the user through a retry.
- **Biometric authentication.** Returning users confirm their identity with the device's biometric check.
- **Session binding (patent pending).** Users confirm browser sign-ins on their enrolled phone, so a stolen password or session token isn't enough on its own.
- **Approval requests.** Users approve or decline requests that your backend sends to their phone.
- **Organization sign-in.** Enrollment can be tied to your organization's own login, such as Okta or another OIDC provider.
- **Mutual TLS.** The SDK registers a client certificate for the device and uses it for its service calls.
- **Branding.** You can set your own colors, fonts, logo, text and language.

## What's new in 3.1.3

- Corrected the Closed and Terminated session-status values to match the service (Terminated = 5, Closed = 6).

## What's new in 3.1.2

- Enrollment retries now send the user to the correct capture step — the front of the document, the back or its barcode, the passport, or the face — instead of a mismatched one.
- A verification that comes back with a failing document image, a low face match, or a failed identity check is now reported as a failure rather than a success, and no account is stored for it.

## What's new in 3.1.1

- Reduced the SDK's public API surface. The presence monitor's internal classes are no longer part of the public interface. The host-facing session-binding and presence APIs are unchanged.

## What's new in 3.1.0

- Session binding status for apps that display the state of a bound browser session.
- The device receives a separate client certificate for real-time session connections.
- The package now declares iOS 18.2, which is the framework's actual minimum. Earlier manifests declared iOS 13.
- The package re-exports the framework's own `VerificationResult` and `BindingEnrollmentResult` instead of compiling separate copies.
- Security hardening. Upgrading is recommended.

See [CHANGELOG.md](CHANGELOG.md) for details and [Upgrading from 3.0](#upgrading-from-30) for what changes in your app.

## Installation

### Xcode

1. Choose **File › Add Package Dependencies…**
2. Enter `https://github.com/artius-iD/sdk`.
3. Choose **Up to Next Major Version** starting at `3.1.0`.
4. Add the **ArtiusIDSDK** product to your app target.

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/artius-iD/sdk", from: "3.1.3")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [.product(name: "ArtiusIDSDK", package: "sdk")]
    )
]
```

The package downloads two dynamic frameworks from the release: `artiusid_sdk_ios` (the SDK) and `OpenSSL`. Xcode embeds and signs both with your app. The SDK doesn't depend on Firebase or any other package.

### Imports

Import the SDK module:

```swift
import artiusid_sdk_ios
```

The package also builds a small `ArtiusIDSDKWrapper` module that offers the same setup call as `ArtiusIDSDKWrapper.shared.configure(...)`. Both modules declare a type named `ArtiusIDSDK`, so in a file that imports both, write `artiusid_sdk_ios.ArtiusIDSDK`. Most apps only need `artiusid_sdk_ios`.

## Setup

### 1. Get credentials

For each environment you use, Artius.iD issues a client ID, a client group ID and the service domains. To request sandbox access, use the [Artius.iD developer portal](https://developer.artiusid.ai).

### 2. Add capabilities and usage descriptions

| Needed for | Add to your app |
|---|---|
| Face and document capture | `NSCameraUsageDescription` |
| Saving or choosing ID images | `NSPhotoLibraryUsageDescription` |
| Biometric confirmation | `NSFaceIDUsageDescription` |
| Passport chip reading | The **Near Field Communication Tag Reading** capability, `NFCReaderUsageDescription`, and `com.apple.developer.nfc.readersession.iso7816.select-identifiers` containing `A0000002471001` |
| Requests from your backend | The **Push Notifications** capability, plus **Background Modes › Remote notifications** |

Session binding needs additional permissions and background modes. Artius.iD provides the exact list with your integration package.

### 3. Configure the SDK at launch

```swift
import SwiftUI
import artiusid_sdk_ios

@main
struct MyApp: App {
    init() {
        ArtiusIDSDK.shared.configure(
            environment: .sandbox,
            urlTemplate: "https://#env#.#domain#",
            mobileDomain: "mobile.artiusid.ai",
            registrationUrlTemplate: "https://#env#.#domain#",
            registrationDomain: "registration.artiusid.ai",
            clientId: CLIENT_ID,             // issued by Artius.iD
            clientGroupId: CLIENT_GROUP_ID   // issued by Artius.iD
        )
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

The SDK replaces `#env#` with the environment's prefix and `#domain#` with the domain you pass. The sandbox values above resolve to `https://sandbox.mobile.artiusid.ai` and `https://sandbox.registration.artiusid.ai`. For every other environment, pass the templates and domains that Artius.iD gives you. Always pass them explicitly instead of relying on defaults.

Optional `configure` parameters:

| Parameter | Default | Purpose |
|---|---|---|
| `verificationOperationMode` | `.bindingEnrollment` | `.bindingEnrollment` enrolls the phone for session binding. `.verify` runs identity verification only. |
| `isThirdPartyLoginEnabled` | `true` | Requires an organization sign-in before enrollment (see [Organization sign-in](#organization-sign-in)). |
| `thirdPartyLoginURL` | `nil` | Your organization sign-in endpoint, as provided by Artius.iD. |
| `includeOktaIDInVerificationPayload` | `true` | Includes the user's Okta ID in the enrollment request. |

Set the other optional parameters only when Artius.iD asks you to.

### 4. Push notifications

The SDK doesn't bundle Firebase, so your app configures Firebase Cloud Messaging and gives the SDK its token:

```swift
// MessagingDelegate
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let fcmToken else { return }
    ArtiusIDSDK.shared.updateFCMToken(fcmToken)
}
```

Hand Artius.iD requests to the SDK when a notification arrives or is tapped:

```swift
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        ArtiusIDPush.route(response.notification.request.content.userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        ArtiusIDPush.route(notification.request.content.userInfo) ? [] : [.banner, .sound]
    }
}

enum ArtiusIDPush {
    /// Passes an Artius.iD request to the SDK. Returns false for any other payload.
    @MainActor @discardableResult
    static func route(_ userInfo: [AnyHashable: Any]) -> Bool {
        let requests = ArtiusID.AppNotificationState.shared
        if let title = userInfo["approvalTitle"] as? String {
            requests.handleApprovalNotification(
                requestId: (userInfo["requestId"] as? String).flatMap { Int($0) },
                title: title,
                description: userInfo["approvalDescription"] as? String ?? "")
            return true
        }
        if let sessionId = userInfo["sessionId"] as? String {
            requests.handleBindingNotification(
                sessionId: sessionId,
                title: userInfo["bindingTitle"] as? String ?? "Sign-in request",
                description: userInfo["bindingDescription"] as? String ?? "")
            return true
        }
        return false
    }
}
```

In your `App`, attach the delegate with `@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate`.

## Enrollment

Present `ArtiusIDVerificationView`. It runs face capture, document capture and submission, then calls back with a `VerificationResult`.

```swift
struct EnrollButton: View {
    @State private var showEnrollment = false

    var body: some View {
        Button("Enroll") { showEnrollment = true }
            .fullScreenCover(isPresented: $showEnrollment) {
                ArtiusIDVerificationView(
                    configuration: .init(clientId: CLIENT_ID, clientGroupId: CLIENT_GROUP_ID, environment: .sandbox),
                    onCompletion: { result in
                        showEnrollment = false
                        handle(result)
                    },
                    onCancel: { showEnrollment = false }
                )
            }
    }

    private func handle(_ result: VerificationResult) {
        if result.requiresRecapture, let recapture = result.recaptureType {
            // The user left a document retry. Offer to start again.
            print("Retry needed: \(recapture.title) - \(recapture.message)")
        } else if result.isSuccessful {
            print("Enrolled account \(result.accountNumber ?? "-")")
        } else {
            print("Enrollment failed: \(result.errorMessage ?? "unknown error")")
        }
    }
}
```

Always check `requiresRecapture` first. The SDK already offers the user a retry for unreadable document images. You only receive this result if the user leaves that retry.

`VerificationResult` also carries `fullName`, `firstName`, `lastName`, `verificationScore`, `faceMatchScore`, `documentStatus` and, in binding-enrollment mode, `bindingEnrollmentResult`.

## Organization sign-in

To sign the user in with your organization's credentials and register the device's push token for that user, call:

```swift
func signIn(loginId: String, password: String) async throws -> String {
    ArtiusIDSDK.shared.setThirdPartyLoginURL(LOGIN_URL)   // provided by Artius.iD
    let result = try await ArtiusIDSDK.shared.validateCredentialsAndRegisterFCM(
        loginId: loginId,
        password: password
    )
    guard result.isSuccessful else {
        throw SignInError(message: result.errorMessage ?? "Sign-in failed")
    }
    return result.loginId ?? loginId
}
```

Call it after the SDK has a push token. To use your own identity provider behind the SDK's sign-in screen, install a handler:

```swift
ArtiusIDSDK.shared.setThirdPartyLoginHandler { loginId, password, environment in
    let accepted = await MyIdentityProvider.verify(loginId, password)
    return .init(isSuccessful: accepted,
                 loginId: accepted ? loginId : nil,
                 errorMessage: accepted ? nil : "Invalid credentials")
}
```

## Session binding and approval requests

After `ArtiusIDPush.route` hands a request to `ArtiusID.AppNotificationState`, present the matching SDK screen. Both screens read the request from the environment object.

```swift
struct ContentView: View {
    @ObservedObject private var requests = ArtiusID.AppNotificationState.shared

    var body: some View {
        HomeView()
            .fullScreenCover(isPresented: isShowing(.binding)) {
                ArtiusID.BindingView(
                    onCompletion: { result in
                        print("Binding \(result.isSuccessful ? "confirmed" : "not confirmed")")
                        requests.reset()
                    },
                    onCancel: { requests.reset() }
                )
                .environmentObject(requests)
            }
            .sheet(isPresented: isShowing(.approval)) {
                ArtiusID.ApprovalView(
                    onCompletion: { decision in
                        print("Approval response: \(decision)")
                        requests.reset()
                    },
                    onCancel: { requests.reset() }
                )
                .environmentObject(requests)
            }
    }

    private func isShowing(_ type: ArtiusID.NotificationType) -> Binding<Bool> {
        Binding(
            get: { requests.notificationType == type },
            set: { if !$0 { requests.reset() } }
        )
    }
}
```

The binding screen needs an enrolled device (see [Enrollment](#enrollment)). Artius.iD provides the browser-side setup and the additional session-binding options with your integration package.

## Returning-user authentication

```swift
ArtiusIDAuthenticationView(
    configuration: .init(clientId: CLIENT_ID, clientGroupId: CLIENT_GROUP_ID,
                         accountNumber: accountNumber, environment: .sandbox),
    onCompletion: { result in
        print(result.isSuccessful ? "Authenticated" : (result.errorMessage ?? result.message))
    },
    onCancel: { }
)
```

`accountNumber` is the value returned by a successful enrollment. Store it in the keychain.

## Branding and language

```swift
ThemeManager.shared.setTheme(
    EnhancedSDKThemeConfiguration(
        brandName: "Acme",
        primaryColorHex: "#1B6EF3",
        secondaryColorHex: "#FF8A00",
        backgroundColorHex: "#FFFFFF",
        logoResourceName: "AcmeLogo"      // an image in your asset catalog
    )
)

LocalizationManager.shared.setLocale(Locale(identifier: "es"))
```

For full control, `EnhancedSDKThemeConfiguration` also accepts `typography`, `colorScheme`, `iconTheme`, `textContent`, `componentStyling`, `layoutConfig` and `animationConfig`. Apply the theme before you present an SDK screen.

## Upgrading from 3.0

- **iOS 18.2 minimum.** Raise your deployment target to 18.2 or later.
- **Result types.** `VerificationResult` and `BindingEnrollmentResult` now come from the framework, under the same names. Code that reads results keeps compiling, and every result field is now available.
- **Certificates.** The first launch after upgrading issues new client certificates for the device and removes the old one. This happens in the background, and users aren't prompted.
- **Sample code.** `Examples/iOS` was written for the 2.x API. The snippets in this README are current for 3.1.3.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Failed to build module 'artiusid_sdk_ios'`, or `module compiled with Swift 6.3 cannot be imported` | Build with Xcode 26.6 or later. |
| `ambiguous use of 'shared'` on `ArtiusIDSDK.shared` | The file imports both `artiusid_sdk_ios` and `ArtiusIDSDKWrapper`. Import one of them, or write `artiusid_sdk_ios.ArtiusIDSDK.shared`. |
| Keychain error `-34018` in the Simulator, or certificates that are never stored | The app was built without code signing. Build with your development team selected. |
| Camera or NFC screens don't work in the Simulator | Enrollment needs a physical device. |
| No push token in the Simulator | Test push on a device. To exercise your routing code, deliver a sample payload with `xcrun simctl push`. |
| Requests arrive, but no screen appears | Make sure `AppNotificationState.shared` is observed and that the SDK view gets it with `.environmentObject(...)`. |

## Support

Request credentials and integration help through the [Artius.iD developer portal](https://developer.artiusid.ai). Company information is at [artiusid.ai](https://www.artiusid.ai).

## License

Copyright © 2024–2026 Artius.iD, Inc. All rights reserved. Your license agreement with Artius.iD governs use of this SDK.
