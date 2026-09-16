# Changelog

All notable changes to this project will be documented in this file.

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
