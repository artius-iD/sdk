# Changelog

All notable changes to this project will be documented in this file.

## [3.2.3] - 2026-10-07

### Changed
- `sendBindingResponse` returns the service's answer for every HTTP status: `statusCode` is the
  HTTP status and `message` the service's own text, so an app can tell a decline the service
  accepted (401) from one it refused because the scanned code had expired (403). `nil` now means
  only that no answer arrived. Treat only `statusCode == 200` as accepted.

## [3.2.2] - 2026-10-07

### Security
- Binding, approval and authentication requests no longer approve without a check when
  biometrics are unavailable. They use Face ID / Touch ID when available, otherwise the device
  passcode, and fail when the device has neither. Previously any biometric error (not enrolled,
  locked out, no hardware) counted as authenticated.

### Fixed
- SDK strings are found for a bare language code whose strings ship under a region: with the
  locale set to Spanish (`es`) every SDK string fell back to English.

## [3.2.1] - 2026-10-05

### Fixed
- Requests no longer stall before sending on a slow DNS resolver. Enrollment could sit on
  Processing for about a minute before the request left the phone.
- Request bodies are no longer written to the system log; only their size is.

## [3.2.0] - 2026-10-05

### Changed
- On-device face matching runs on a new engine with separate selfie and ID-portrait models.
  Thresholds come from configuration (`FaceEngineV2Configuration`), and every result records the
  threshold and model version it used.
- **The face-matching models are not included in this release.** A host app supplies them in its
  bundle (see the integration guide). Without them, face matching reports that it is unavailable
  and the rest of the SDK works as before. Evaluation partners can request the models from
  artius.iD.
- The real-time session connection authenticates with a session token instead of a client
  certificate, and reconnects once automatically after an unexpected drop.
- A session the service hard-locks is treated as ended.

### Added
- `ArtiusIDSDK.bindingSession`: a snapshot of the bound session (status, why each side is locked,
  pairing, whether the browser is connected, expiry warning), with update notifications.
- `ArtiusIDSDK.resumeBindingWebSocketIfNeeded()` reconnects a dropped session connection, for
  example when the app returns to the foreground.
- Stopping presence monitoring while a session is bound now locks the session until monitoring
  resumes.

### Removed
- The separate client certificate for the real-time session connection.

## [3.1.4] - 2026-09-25

### Added
- `verifyEnrolledAccount()` checks with the service that the device's enrolled account still
  exists and returns `.active`, `.inactive` or `.unreachable`. `.inactive` means the service has
  no active account for the device, so it is safe to start enrollment again.

### Changed
- Session binding: a lock caused by the phone being away is reported as such, so a paired browser
  shows a phone-away notice instead of an inactivity prompt and resumes when the phone returns.
- Updated certificate pinning for the real-time session connection.

## [3.1.3] - 2026-09-22

### Fixed
- Corrected the Closed and Terminated session-status values to match the service
  (Terminated = 5, Closed = 6).

## [3.1.2] - 2026-09-22

### Fixed
- Enrollment retries send the user to the correct capture step (the front of the document, the
  back or its barcode, the passport, or the face) instead of a mismatched one.
- A verification that comes back with a failing document image, a low face match or a failed
  identity check is reported as a failure rather than a success, and no account is stored for it.

## [3.1.1] - 2026-09-16

### Changed
- Reduced the public API surface: the presence monitor's internal classes are no longer
  part of the framework's public interface. The host-facing session-binding and presence
  APIs are unchanged.

## [3.1.0] - 2026-09-16

### Added
- Session binding status for apps that display the state of a bound browser session:
  `ArtiusIDSDK.bindingSessionStatusNotification`, `onBindingSessionStatusChange` and
  `bindingSessionStatus`.
- A separate client certificate for real-time session connections (`CertificatePurpose`).

### Changed
- The package declares iOS 18.2, which is the framework's minimum. Earlier manifests declared iOS 13.
- The package re-exports the framework's `VerificationResult` and `BindingEnrollmentResult`
  instead of compiling its own copies.
- The first launch after upgrading issues new client certificates for the device and removes the
  old one. Users aren't prompted.
- Release binaries are no longer committed to the repository; they are attached to each GitHub
  release.

### Security
- Security hardening. Upgrading is recommended.

Releases 2.0.140 through 3.0.11 are listed on the
[releases page](https://github.com/artius-iD/sdk/releases).

## [2.0.139] - 2026-03-04

### Changed
- Expose SDK version using wrapper
- Updated version constants

## [2.0.138] - 2026-03-03

### Added
- Approval Request Result localization enhancements
- Fully localized SampleAppSettingsView

### Fixed
- Fixed approval result display to show "Approved" or "Declined" instead of "yes" or "no"
- Fixed approval result card title to display "Approval Request Result"

## [2.0.137]

### Changed
- Version bump

## [2.0.136]

### Changed
- Version bump

## [2.0.135]

### Changed
- Version bump

## [2.0.134]

### Changed
- Version bump

---

For integration instructions, see [README.md](README.md).
