import SwiftUI
import Combine
import artiusid_sdk_ios

/// ViewModel for the sample app demonstrating SDK integration patterns
///
/// **Key Responsibilities:**
/// - **SDK Initialization**: Configure SDK with themes and image overrides before launching flows
/// - **Theme Management**: Handle theme updates and persist selections
/// - **Environment Switching**: Switch between SDK environments (Sandbox, Development, Staging)
/// - **Credential Tracking**: Monitor FCM tokens, certificates, and account numbers
/// - **State Management**: Provide published properties for UI binding and reactive updates
///
/// **For SDK Users:** This shows how to:
/// 1. Initialize the SDK after theme selection (`initializeSDK()`)
/// 2. Update environment with certificate registration (`updateEnvironment()`)
/// 3. Refresh credentials when configuration changes (`refreshCredentialStatusFromKeychain()`)
/// 4. Observe and react to external changes (theme, language, environment)
///
class SampleAppViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentTheme: ThemeOption = .artiusDefault
    @Published var imageOverrideScenario: ImageOverrideOption = .default
    @Published var currentEnvironment: EnvironmentConfig.Environment = .sandbox
    
    @Published var isOktaIdEnabled: Bool = false
    @Published var isSDKInitialized: Bool = false
    @Published var isLoading: Bool = false
    @Published var isApprovalLoading: Bool = false
    
    @Published var lastResult: String = ""
    @Published var fcmTokenStatus: String = ""
    @Published var fcmTokenPreview: String = ""
    @Published var certificateStatus: String = ""
    @Published var accountNumberStatus: String = ""
    @Published var accountNumberPreview: String = ""
    @Published var isUpdatingEnvironment: Bool = false
    
    private var rootViewController: UIViewController?
    private var cancellables = Set<AnyCancellable>()
    private var clearCredentialsWorkItem: DispatchWorkItem?
    
    // Computed properties for localized status strings
    private var localizedNotAvailable: String {
        LocalizationManager.shared.string(forKey: "sample_status_not_available")
    }
    
    private var localizedNotLoaded: String {
        LocalizationManager.shared.string(forKey: "sample_status_not_loaded")
    }
    
    private var localizedAvailable: String {
        LocalizationManager.shared.string(forKey: "sample_status_available")
    }
    
    private var localizedLoaded: String {
        LocalizationManager.shared.string(forKey: "sample_status_loaded")
    }
    
    // MARK: - Initializer
    
    init() {
        self.currentEnvironment = environmentFromStoredValue(EnvironmentManager.shared.getCurrentEnvironment())

        // Load saved theme from AppThemeManager
        let savedTheme = AppThemeManager.shared.currentTheme
        
        switch savedTheme {
        case .dark:
            self.currentTheme = .darkTheme
        case .corporateBlue:
            self.currentTheme = .corporateBlue
        default:
            self.currentTheme = .artiusDefault
        }
        
        // Initialize status strings with localized values
        self.fcmTokenStatus = LocalizationManager.shared.string(forKey: "sample_status_not_available")
        self.certificateStatus = LocalizationManager.shared.string(forKey: "sample_status_not_loaded")
        self.accountNumberStatus = LocalizationManager.shared.string(forKey: "sample_status_not_available")
        
        setupObservers()
        
        // Check for existing FCM token on init
        updateFCMTokenStatus()
        
        logInfo("SampleAppViewModel initialized", source: "SampleAppViewModel")
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Observe theme changes
        $currentTheme
            .sink { [weak self] _ in
                self?.initializeSDK()
            }
            .store(in: &cancellables)
        
        // Observe environment changes
        $currentEnvironment
            .sink { [weak self] _ in
                self?.refreshCredentialStatusFromKeychain()
            }
            .store(in: &cancellables)
        
        // Observe language changes from LocalizationManager
        NotificationCenter.default.publisher(for: .languageDidChange)
            .sink { [weak self] _ in
                self?.updateLocalizedStatuses()
            }
            .store(in: &cancellables)
    }
    
    /// Update status strings when language changes
    private func updateLocalizedStatuses() {
        // Refresh with localized strings - this will update the status
        updateFCMTokenStatus()
        self.certificateStatus = LocalizationManager.shared.string(forKey: "sample_status_not_loaded")
        self.accountNumberStatus = LocalizationManager.shared.string(forKey: "sample_status_not_available")
    }
    
    // MARK: - SDK Initialization
    
    /// **CRITICAL:** Initialize SDK with current theme and image overrides before launching any flow
    ///
    /// This must be called:
    /// - After theme is selected/changed
    /// - Before showing `ArtiusIDVerificationView`, `ArtiusIDAuthenticationView`, or `ArtiusID.ApprovalView`
    /// - When image overrides are updated
    ///
    /// Updates `ThemeManager` and `ImageOverrideManager` to apply customizations globally to all SDK flows.
    func initializeSDK() {
        logInfo("Initializing SDK with theme: \(currentTheme.displayName)", source: "SampleAppViewModel")

        ImageOverrideManager.shared.setLogging(enabled: false)

        let selectedTheme = currentTheme.themeConfig
        ThemeManager.shared.setTheme(selectedTheme)
        logInfo("Applied SDK theme: \(selectedTheme.brandName)", source: "SampleAppViewModel")
        
        if let overrides = imageOverrideScenario.overrides {
            ImageOverrideManager.shared.setConfiguration(overrides)
            logInfo("Applied image overrides from scenario: \(imageOverrideScenario.displayName) (\(imageOverrideScenario.customizationCount) properties)", source: "SampleAppViewModel")
        } else {
            ImageOverrideManager.shared.clearOverrides()
            logInfo("Cleared image overrides - using SDK defaults", source: "SampleAppViewModel")
        }
        
        isSDKInitialized = true
        logInfo("SDK initialized successfully", source: "SampleAppViewModel")
    }
    
    /// Update credential status when environment changes or view reappears
    ///
    /// Call this when:  
    /// - User switches environments
    /// - View appears after being dismissed (credentials may have changed)
    /// - Verification completes (account number becomes available)
    func refreshCredentialStatusFromKeychain() {
        logInfo("Refreshing credentials from keychain for environment: \(currentEnvironment.displayName)", source: "SampleAppViewModel")
        updateFCMTokenStatus()
        updateAccountNumberStatus()
        updateCertificateStatus()
    }
    
    func setRootViewController(_ viewController: UIViewController) {
        self.rootViewController = viewController
        logDebug("Root view controller set", source: "SampleAppViewModel")
    }
    
    // MARK: - Theme Management
    
    /// Apply a new theme and persist the selection
    ///
    /// Triggers `initializeSDK()` automatically via published property observer.
    func updateTheme(_ theme: ThemeOption) {
        currentTheme = theme
        
        // Sync with AppThemeManager to persist the change
        let mappedTheme: SimplifiedThemeListing
        switch theme {
        case .darkTheme:
            mappedTheme = .dark
        case .corporateBlue:
            mappedTheme = .corporateBlue
        default:
            mappedTheme = .artiusID
        }
        
        AppThemeManager.shared.currentTheme = mappedTheme
        
        logInfo("Theme updated to: \(theme.displayName)", source: "SampleAppViewModel")
    }
    
    // MARK: - Image Override Management
    
    /// Update image override scenario and reapply to SDK
    ///
    /// Image overrides customize icons, buttons, logos throughout SDK flows.
    /// See `ImageOverrideOption` for available scenarios.
    func updateImageOverrideScenario(_ scenario: ImageOverrideOption) {
        imageOverrideScenario = scenario
        logInfo("Image override scenario updated to: \(scenario.displayName)", source: "SampleAppViewModel")
        initializeSDK()
    }
    
    // MARK: - Environment Management
    
    /// Switch to a different SDK environment and register certificate
    ///
    /// When switching environments:
    /// 1. Validates environment is different
    /// 2. Updates EnvironmentManager
    /// 3. Calls `ensureCertificateRegistered()` (async)
    /// 4. Refreshes credential status
    ///
    /// Call before launching verification/authentication flows in a new environment.
    func updateEnvironment(_ environment: EnvironmentConfig.Environment) {
        guard currentEnvironment != environment else {
            logInfo("Environment unchanged: \(environment.displayName)", source: "SampleAppViewModel")
            refreshCredentialStatusFromKeychain()
            return
        }

        isUpdatingEnvironment = true
        currentEnvironment = environment
        EnvironmentManager.shared.setEnvironment(environment.displayName)

        let config = EnvironmentConfig.configForEnvironment(environment)
        _ = config.toSDKConfiguration(
            includeOktaIDInVerificationPayload: isOktaIdEnabled
        )

        certificateStatus = LocalizationManager.shared.string(forKey: "gen_processing")

        Task {
            let startTime = Date()
            do {
                _ = try await ArtiusIDSDK.shared.ensureCertificateRegistered()
                
                // Ensure spinner shows for at least 500ms for user feedback
                let elapsed = Date().timeIntervalSince(startTime)
                let minimumDisplayTime: TimeInterval = 0.5
                if elapsed < minimumDisplayTime {
                    try await Task.sleep(nanoseconds: UInt64((minimumDisplayTime - elapsed) * 1_000_000_000))
                }
                
                await MainActor.run {
                    self.refreshCredentialStatusFromKeychain()
                    self.isUpdatingEnvironment = false
                }
            } catch {
                await MainActor.run {
                    self.certificateStatus = LocalizationManager.shared.string(forKey: "sample_status_not_loaded")
                    self.isUpdatingEnvironment = false
                }
                logError("Failed to ensure certificate for environment \(environment.displayName): \(error)", source: "SampleAppViewModel")
            }
        }

        logInfo("Environment updated to: \(environment.displayName)", source: "SampleAppViewModel")
    }
    
    // MARK: - Okta ID Management
    
    func updateOktaIdEnabled(_ enabled: Bool) {
        isOktaIdEnabled = enabled
        logInfo("Okta ID \(enabled ? "enabled" : "disabled")", source: "SampleAppViewModel")
    }
    
    // MARK: - SDK Flows
    
    func startVerification() {
        logInfo("Starting verification flow", source: "SampleAppViewModel")
        isLoading = true
        
        // Simulate verification flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.lastResult = LocalizationManager.shared.string(forKey: "sample_result_verification_complete")
            self.isLoading = false
            logInfo("Verification flow completed", source: "SampleAppViewModel")
        }
    }
    
    func startAuthentication() {
        logInfo("Starting authentication flow", source: "SampleAppViewModel")
        isLoading = true
        
        // Simulate authentication flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.lastResult = LocalizationManager.shared.string(forKey: "sample_result_authentication_complete")
            self.isLoading = false
            logInfo("Authentication flow completed", source: "SampleAppViewModel")
        }
    }
    
    func testApprovalProcess(onStatusUpdate: ((String) -> Void)? = nil) {
        logInfo("Testing approval process", source: "SampleAppViewModel")
        cancelPendingClearCredentialsWork()
        isApprovalLoading = true
        lastResult = LocalizationManager.shared.string(forKey: "gen_processing")
        onStatusUpdate?(lastResult)
        
        // Call the SDK to send the actual approval request
        Task {
            let result = await ArtiusIDSDK.shared.sendApprovalRequest()

            await MainActor.run {
                if result.success {
                    if let requestId = result.requestId {
                        self.lastResult = "✅ \(result.message) (requestId: \(requestId))"
                    } else {
                        self.lastResult = "✅ \(result.message)"
                    }
                    onStatusUpdate?(self.lastResult)
                    logInfo("Approval request sent successfully: \(result.message)", source: "SampleAppViewModel")
                } else {
                    self.lastResult = "❌ \(result.message)"
                    onStatusUpdate?(self.lastResult)
                    logError("Approval request failed: \(result.message)", source: "SampleAppViewModel")
                }
                self.isApprovalLoading = false
            }
        }
    }
    
    // MARK: - Credential Management
    
    func clearAllCredentials() {
        logInfo("Clearing all credentials", source: "SampleAppViewModel")
        clearCredentialsWorkItem?.cancel()
        isLoading = true
        
        // Clear credentials
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard !(self.clearCredentialsWorkItem?.isCancelled ?? true) else { return }

            // Clear sample-app persisted verification/authentication values
            AppPreferences.remove(forKey: .verificationAccountNumber)
            AppPreferences.remove(forKey: .authenticationAccountNumber)
            AppPreferences.remove(forKey: .accountFullName)

            // Clear SDK credentials and FCM tokens
            CertificateManager.shared.clearAllCredentials()
            KeychainHelper.standard.clearAllFCMTokens()
            
            // Clear member IDs from SDK keychain for all environments
            let sdkKeychain = KeychainHelper(service: "artiusid.dev")
            let environments = ["sandbox", "development", "staging"]
            for env in environments {
                let memberIdKey = "verification-\(env)"
                try? sdkKeychain.remove(memberIdKey)
            }

            // Reset in-memory status previews
            self.fcmTokenPreview = ""
            self.accountNumberPreview = ""
            self.certificateStatus = LocalizationManager.shared.string(forKey: "sample_status_not_loaded")
            self.accountNumberStatus = LocalizationManager.shared.string(forKey: "sample_status_not_available")

            self.lastResult = LocalizationManager.shared.string(forKey: "sample_result_credentials_cleared")
            self.isLoading = false
            self.refreshCredentialStatusFromKeychain()
            logInfo("Credentials cleared", source: "SampleAppViewModel")
        }
        clearCredentialsWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }

    private func cancelPendingClearCredentialsWork() {
        clearCredentialsWorkItem?.cancel()
        clearCredentialsWorkItem = nil
        if isLoading {
            isLoading = false
        }
    }
    
    // MARK: - FCM Management
    
    func refreshFCMToken() {
        logInfo("Refreshing FCM token", source: "SampleAppViewModel")
        
        // Show initial result
        self.lastResult = LocalizationManager.shared.string(forKey: "sample_result_fcm_refreshed")
        
        // Trigger FCM token refresh in Firebase service
        SampleFirebaseMessagingService.shared.refreshToken()
        
        // Update status after a short delay to show the refreshed token
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateFCMTokenStatus()
        }
        
        logInfo("FCM token refresh initiated", source: "SampleAppViewModel")
    }
    
    /// Update FCM token status from keychain
    private func updateFCMTokenStatus() {
        let currentEnv = currentEnvironment.rawValue
        let keychain = KeychainHelper.standard
        
        if let token = keychain.getFCMToken(for: currentEnv) {
            self.fcmTokenStatus = LocalizationManager.shared.string(forKey: "sample_status_available")
            // Show preview of token (first 20 characters)
            self.fcmTokenPreview = String(token.prefix(20)) + "..."
            ArtiusIDSDK.shared.updateFCMToken(token)
        } else {
            self.fcmTokenStatus = LocalizationManager.shared.string(forKey: "sample_status_not_available")
            self.fcmTokenPreview = ""
        }
    }

    /// Update account number status from keychain
    /// The SDK stores account number in keychain service "artiusid.dev" with key "verification-{environment}"
    private func updateAccountNumberStatus() {
        let currentEnv = currentEnvironment.rawValue.lowercased()
        // SDK uses "artiusid.dev" service for account number storage
        let sdkKeychain = KeychainHelper(service: "artiusid.dev")
        let accountNumberKey = "verification-\(currentEnv)"
        
        if let accountNumber = sdkKeychain[accountNumberKey], !accountNumber.isEmpty {
            self.accountNumberStatus = LocalizationManager.shared.string(forKey: "sample_status_available")
            // Show preview of account number (first 20 characters)
            self.accountNumberPreview = String(accountNumber.prefix(20)) + (accountNumber.count > 20 ? "..." : "")
        } else {
            self.accountNumberStatus = LocalizationManager.shared.string(forKey: "sample_status_not_available")
            self.accountNumberPreview = ""
        }
    }

    private func updateCertificateStatus() {
        self.certificateStatus = CertificateManager.shared.hasCertificate()
            ? LocalizationManager.shared.string(forKey: "sample_status_loaded")
            : LocalizationManager.shared.string(forKey: "sample_status_not_loaded")
    }

    private func environmentFromStoredValue(_ value: String) -> EnvironmentConfig.Environment {
        switch value.lowercased() {
        case "sandbox":
            return .sandbox
        case "development", "dev":
            return .development
        case "staging", "stage":
            return .staging
        default:
            return .sandbox
        }
    }
}
