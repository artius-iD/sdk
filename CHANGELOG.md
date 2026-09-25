# Changelog

All notable changes to this project will be documented in this file.

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
