//
//  SampleAppView.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 10/29/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import SwiftUI
import Combine
import artiusid_sdk_ios

// MARK: - Main sample app view - demonstrates how to use the ArtiusID SDK
///
/// This view shows the three core SDK flows:
/// 1. **Verification Flow**: Capture and verify user identity
/// 2. **Authentication Flow**: Authenticate a previously verified user
/// 3. **Approval Flow**: Request user approval (e.g., for transactions)
///
/// **For SDK Users:** Follow this pattern for each flow:
/// - **Button Action**: Initialize (`applySelectedSDKTheme()`, reset state)
/// - **SDK Launch**: Show full-screen cover with SDK view (`ArtiusIDVerificationView`, etc.)
/// - **Callback Handling**: Handle completion/cancellation with result callback
/// - **Data Storage**: Store results (account number, tokens) for future use
/// - **Display**: Show result card with status and details
///
/// See the flow-specific sections (// MARK: - Verification Flow, etc.) for complete examples.
struct SampleAppView: View {
    @StateObject private var viewModel = SampleAppViewModel()
    @StateObject private var appNotificationState = ArtiusID.AppNotificationState.shared
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: AppThemeManager
    
    @State private var showingVerification = false
    @State private var showingAuthentication = false
    @State private var showingApproval = false
    @State private var showingSettings = false
    
    // Result tracking states
    @State private var verificationResult: VerificationResult? = nil
    @State private var isVerificationComplete = false
    @State private var authenticationResult: String? = nil
    @State private var isAuthenticationComplete = false
    @State private var approvalResult: String? = nil
    @State private var lastActionType: String = "" // "verification", "authentication", "approval", "clear", "fcm"

    private var selectedSDKEnvironment: ArtiusIDVerificationView.ArtiusIDEnvironment {
        switch viewModel.currentEnvironment {
        case .sandbox:
            return .sandbox
        case .development:
            return .development
        case .staging:
            return .staging
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header Section
                        headerSection
                        
                        // Action Buttons
                        actionButtonsSection
                        
                        // Show only the most recent result
                        if lastActionType == "verification", let result = verificationResult {
                            verificationResultsSection(result)
                        } else if lastActionType == "authentication", let result = authenticationResult {
                            authenticationResultsSection(result)
                        } else if lastActionType == "approval" {
                            approvalResultCard
                        } else if lastActionType == "clear" || lastActionType == "fcm" {
                            lastResultCard
                        }
                    }
                    .padding(16)
                }
                .background(backgroundColor)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {  showingSettings = true }) {
                            Image(systemName: "gear")
                                .foregroundColor(textColor)
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingVerification) {
                    // SDK Public API: Verification View
                    ArtiusIDVerificationView(
                        configuration: ArtiusIDVerificationView.Configuration(
                            clientId: 12345,
                            environment: selectedSDKEnvironment,
                            preferredDocumentType: .passport
                        ),
                        onCompletion: { result in
                            logInfo("Verification completed: \(result.isSuccessful ? "Success" : "Failed")", source: "SampleAppView")
                            if let error = result.errorMessage {
                                logWarning("Verification error: \(error)", source: "SampleAppView")
                            }
                            DispatchQueue.main.async {
                                self.handleVerificationResult(result)
                                showingVerification = false
                            }
                        },
                        onCancel: {
                            logInfo("Verification cancelled", source: "SampleAppView")
                            verificationResult = nil
                            isVerificationComplete = false
                            showingVerification = false
                        }
                    )
                }
                .fullScreenCover(isPresented: $showingApproval) {
                    // SDK Public API: Approval View
                    ArtiusID.ApprovalView(
                        onCompletion: { result in
                            lastActionType = "approval"
                            approvalResult = String(describing: result)
                            // Step 2: Show the actual response (approval or declination)
                            let responseMessage = String(describing: result)
                            viewModel.lastResult = responseMessage
                            logInfo("Approval response received: \(result)", source: "SampleAppView")
                            showingApproval = false
                            appNotificationState.reset()
                        },
                        onCancel: {
                            logInfo("Approval cancelled", source: "SampleAppView")
                            showingApproval = false
                            appNotificationState.reset()
                        }
                    )
                    .environmentObject(appNotificationState)
                }
        }
        .fullScreenCover(isPresented: $showingAuthentication) {
            // SDK Public API: Authentication View
            // Use account number from verification, fallback to test account
            let storedAccountNumber = AppPreferences.get(forKey: .verificationAccountNumber) ?? "test-account"
            
            ArtiusIDAuthenticationView(
                configuration: ArtiusIDAuthenticationView.Configuration(
                    clientId: 1,
                    clientGroupId: 1,
                    accountNumber: storedAccountNumber,
                    environment: selectedSDKEnvironment,
                    authenticationTitle: "Authenticate",
                    authenticationReason: "Please authenticate to continue"
                ),
                onCompletion: { result in
                    logInfo("Authentication completed: \(result.isSuccessful ? "Success" : "Failed")", source: "SampleAppView")
                    if let error = result.errorMessage {
                        logWarning("Authentication error: \(error)", source: "SampleAppView")
                    }
                    DispatchQueue.main.async {
                        self.handleAuthenticationResult(result, isSuccessful: result.isSuccessful)
                        showingAuthentication = false
                    }
                },
                onCancel: {
                    logInfo("Authentication cancelled", source: "SampleAppView")
                    authenticationResult = nil
                    isAuthenticationComplete = false
                    showingAuthentication = false
                }
            )
        }
        }
        .sheet(isPresented: $showingSettings) {
            SampleAppSettingsView(viewModel: viewModel)
                .environmentObject(languageManager)
        }
        .onChange(of: appNotificationState.notificationType) { _, newType in
            // Observe notification state changes (matches Android LaunchedEffect)
            logInfo("Notification type changed to: \(newType)", source: "SampleAppView")
            
            switch newType {
            case .approval:
                logInfo("Opening approval screen for notification", source: "SampleAppView")
                applySelectedSDKTheme()
                showingApproval = true
            case .default:
                logInfo("Default notification state", source: "SampleAppView")
            @unknown default:
                logInfo("Unknown notification type: \(newType)", source: "SampleAppView")
            }
        }
        .onAppear {
            // ✅ CRITICAL: Always fetch credentials from keychain based on current environment
            // Matches Android: onCreate() checks credentials every time activity is created
            logInfo("Home screen appeared - fetching credentials for current environment", source: "SampleAppView")
            
            // Initialize SDK only if not already initialized
            if !viewModel.isSDKInitialized {
                viewModel.initializeSDK()
            } else {
                // ✅ ALWAYS refresh credentials from keychain based on current environment
                // This ensures we show correct status when switching environments or navigating back
                viewModel.refreshCredentialStatusFromKeychain()
            }
            
            // Set root view controller for bridge calls
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    // Navigate to topmost view controller
                    var topController = rootVC
                    while let presented = topController.presentedViewController {
                        topController = presented
                    }
                    if let nav = topController as? UINavigationController {
                        topController = nav.visibleViewController ?? nav
                    }
                    viewModel.setRootViewController(topController)
                }
            }
        }
    }
    
    // MARK: - Main Layout Sections
    
    // MARK: Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(languageManager.localize("sample_header_title"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            
            Text(languageManager.localize("sample_header_subtitle"))
                .font(.body)
                .foregroundColor(textColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
        }
    }
    
    
    // MARK: Action Buttons
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Start Verification Button - HARDCODED dark blue (matching Android)
            Button(action: {
                logInfo("Start Verification button tapped", source: "SampleAppView")
                verificationResult = nil
                isVerificationComplete = false
                applySelectedSDKTheme()
                showingVerification = true
            }) {
                Text(languageManager.localize("sample_verification"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(primaryButtonColor)
                    .cornerRadius(8)
            }
            
            // Start Authentication Button - HARDCODED orange (matching Android)
            Button(action: {
                logInfo("Start Authentication button tapped", source: "SampleAppView")
                
                // Check if account number is available from verification
                let storedAccountNumber = UserDefaults.standard.string(forKey: "verificationAccountNumber")
                if storedAccountNumber == nil {
                    logWarning("No account number from verification. Please run verification first.", source: "SampleAppView")
                } else {
                    logInfo("Using account number from verification: \(storedAccountNumber!)", source: "SampleAppView")
                }
                
                authenticationResult = nil
                isAuthenticationComplete = false
                applySelectedSDKTheme()
                showingAuthentication = true
            }) {
                Text(languageManager.localize("sample_authentication"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(secondaryButtonColor)
                    .cornerRadius(8)
            }
            
            // Test Approval Process Button - HARDCODED green (matching Android)
            Button(action: {
                logInfo("Test Approval button tapped", source: "SampleAppView")
                applySelectedSDKTheme()
                lastActionType = "approval"
                approvalResult = LocalizationManager.shared.string(forKey: "sample_result_approval_request_sent")
                viewModel.lastResult = approvalResult ?? ""
                // Call the test approval process to send the request
                viewModel.testApprovalProcess { status in
                    DispatchQueue.main.async {
                        approvalResult = status
                    }
                }
            }) {
                Text(languageManager.localize("sample_approval"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0))
                    .cornerRadius(8)
            }
            
            // Clear All Credentials Button - HARDCODED red (matching Android)
            Button(action: {
                lastActionType = "clear"
                verificationResult = nil
                isVerificationComplete = false
                authenticationResult = nil
                isAuthenticationComplete = false
                approvalResult = nil
                appNotificationState.reset()
                viewModel.clearAllCredentials()
            }) {
                Text(languageManager.localize("sample_clear_credentials"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0xD3/255.0, green: 0x2F/255.0, blue: 0x2F/255.0))
                    .cornerRadius(8)
            }
            
            // Refresh FCM Token Button - hidden for now
//            Button(action: {
//                viewModel.refreshFCMToken()
//            }) {
//                Text(languageManager.localize("sample_refresh_fcm"))
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(textColor)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 48)
//                    .background(Color.clear)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(textColor, lineWidth: 1)
//                    )
//            }
        }
    }
    
    // MARK: Result Display
    
    /// Shows the last result from any action (clear, fcm, etc.)
    private var lastResultCard: some View {
        Group {
            if !viewModel.lastResult.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Result Header
                        Text(languageManager.localize("sample_last_result"))
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        // Result Text
                        Text(viewModel.lastResult)
                            .font(.body)
                            .foregroundColor(textColor)
                            .padding(8)
                        
                        Divider()
                        
                        // FCM Token Status
                        VStack(alignment: .leading, spacing: 4) {
                            Text(languageManager.localize("sample_fcm_status"))
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            HStack {
                                Text(languageManager.localize("sample_status_label"))
                                    .font(.caption)
                                Text(viewModel.fcmTokenStatus)
                                    .font(.caption)
                                    .foregroundColor(viewModel.fcmTokenStatus.contains("✅") ? Color(hex: "#4CAF50") : Color(hex: "#F44336"))
                            }
                            
                            if !viewModel.fcmTokenPreview.isEmpty {
                                Text(languageManager.localize("sample_token_label") + " \(viewModel.fcmTokenPreview)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                        
                        // Client Certificate Status
                        VStack(alignment: .leading, spacing: 4) {
                            Text(languageManager.localize("sample_cert_status"))
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            HStack {
                                Text(languageManager.localize("sample_status_label"))
                                    .font(.caption)
                                Text(viewModel.certificateStatus)
                                    .font(.caption)
                                    .foregroundColor(viewModel.certificateStatus.contains("✅") ? Color(hex: "#4CAF50") : Color(hex: "#F44336"))
                            }
                        }
                        
                        Divider()
                        
                        // Account Number Status
                        VStack(alignment: .leading, spacing: 4) {
                            Text(languageManager.localize("sample_account_number_status"))
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            HStack {
                                Text(languageManager.localize("sample_status_label"))
                                    .font(.caption)
                                Text(viewModel.accountNumberStatus)
                                    .font(.caption)
                                    .foregroundColor(viewModel.accountNumberStatus.contains("✅") ? Color(hex: "#4CAF50") : Color(hex: "#F44336"))
                            }
                            
                            if !viewModel.accountNumberPreview.isEmpty {
                                Text(languageManager.localize("sample_account_number_label") + " \(viewModel.accountNumberPreview)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }

    
    // MARK: - Approval Flow
    
    /// Displays approval request result
    private var approvalResultCard: some View {
        Group {
            if let result = approvalResult, !result.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizationManager.shared.string(forKey: "sample_approval_request_result", fallback: "Approval Request Result"))
                            .font(.headline)
                            .foregroundColor(textColor)

                        Text(getApprovalDisplayValue(result))
                            .font(.body)
                            .foregroundColor(textColor)
                            .padding(8)
                    }
                }
            }
        }
    }
    
    /// Converts approval result string to display-friendly value
    private func getApprovalDisplayValue(_ result: String) -> String {
        if result.lowercased() == "yes" {
            return LocalizationManager.shared.string(forKey: "approved", fallback: "Approved")
        } else if result.lowercased() == "no" {
            return LocalizationManager.shared.string(forKey: "declined", fallback: "Declined")
        } else {
            return result
        }
    }
    
    
    // MARK: - Verification Flow
    
    /// Displays verification result with personal info, scores, and risk assessment
    private func verificationResultsSection(_ result: VerificationResult) -> some View {
        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    // Result Header with Status Badge
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Verification Result")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            HStack(spacing: 8) {
                                Image(systemName: verificationIconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(verificationIconColor)
                                
                                Text(verificationStatusTitle)
                                    .font(.headline)
                                    .foregroundColor(verificationIconColor)
                            }
                        }
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Personal Information
                    if hasPersonalInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Personal Information")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(textColor)
                            
                            if let fullName = result.fullName {
                                InfoRow(label: "Full Name", value: fullName, textColor: textColor)
                            }
                            
                            if let firstName = result.firstName {
                                InfoRow(label: "First Name", value: firstName, textColor: textColor)
                            }
                            
                            if let lastName = result.lastName {
                                InfoRow(label: "Last Name", value: lastName, textColor: textColor)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Account Information
                    if let accountNumber = result.accountNumber {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Account Information")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(textColor)
                            
                            InfoRow(label: "Account Number", value: accountNumber, textColor: textColor)
                        }
                        
                        Divider()
                    }
                    
                    // Verification Scores
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification Scores")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        InfoRow(label: "Verification Score", value: String(format: "%.1f", result.verificationScore), textColor: textColor)
                    }
                    
                    Divider()
                    
                    // Document Quality & Face Metrics
                    if hasDocumentMetrics {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Document Quality & Face Metrics")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(textColor)
                            
                            if let documentScore = result.documentScore {
                                InfoRow(label: "Document Score", value: String(documentScore), textColor: textColor)
                            }
                            
                            InfoRow(label: "Face Match Score", value: String(result.faceMatchScore), textColor: textColor)
                            
                            if let antiSpoofingScore = result.antiSpoofingFaceScore {
                                InfoRow(label: "Anti-Spoofing Score", value: String(antiSpoofingScore), textColor: textColor)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Risk Assessment Results
                    if hasRiskInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Risk Assessment")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(textColor)
                            
                            if let personScore = result.personScore {
                                InfoRow(label: "Person Score", value: String(format: "%.1f", personScore), textColor: textColor)
                            }
                            
                            if let personResult = result.personResult {
                                InfoRow(label: "Person Result", value: personResult, textColor: textColor)
                            }
                            
                            if let personRating = result.personRating {
                                InfoRow(label: "Person Rating", value: personRating, textColor: textColor)
                            }
                            
                            if let riskScore = result.riskInformationScore {
                                InfoRow(label: "Risk Information Score", value: String(riskScore), textColor: textColor)
                            }
                            
                            if let riskResult = result.riskInformationResult {
                                InfoRow(label: "Risk Information Result", value: riskResult, textColor: textColor)
                            }
                            
                            if let riskRating = result.riskInformationRating {
                                InfoRow(label: "Risk Information Rating", value: riskRating, textColor: textColor)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Additional Information
                    if hasAdditionalInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Information")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(textColor)
                            
                            InfoRow(label: "Requires Recapture", value: result.requiresRecapture ? "Yes" : "No", textColor: textColor)
                            
                            if let recaptureType = result.recaptureType {
                                InfoRow(label: "Recapture Type", value: String(describing: recaptureType), textColor: textColor)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Error Information
                    if let errorMessage = result.errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Error Information")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#F44336"))
                            
                            Text(errorMessage)
                                .font(.system(size: 12))
                                .foregroundColor(textColor)
                                .lineLimit(nil)
                        }
                    }
                }
            }
        }
    }
    
    /// Handles the result from the verification flow
    /// - Stores account number and full name for future use
    /// - Updates UI with result data
    private func handleVerificationResult(_ result: VerificationResult) {
        lastActionType = "verification"
        logInfo("handleVerificationResult called with success: \(result.isSuccessful)", source: "SampleAppView")
        
        if result.isSuccessful {
            // Store account number for future authentication
            if let accountNumber = result.accountNumber {
                UserDefaults.standard.set(accountNumber, forKey: "verificationAccountNumber")
                logInfo("Stored account number: \(accountNumber)", source: "SampleAppView")
            }
            
            // Store full name for UI display
            if let fullName = result.fullName {
                UserDefaults.standard.set(fullName, forKey: "accountFullName")
                logInfo("Stored full name: \(fullName)", source: "SampleAppView")
            }
            
            logInfo("Verification successful! Score: \(result.verificationScore)", source: "SampleAppView")
        } else {
            // Log verification failure details
            if let errorMessage = result.errorMessage {
                logWarning("Verification failed: \(errorMessage)", source: "SampleAppView")
            } else {
                logWarning("Verification failed with score: \(result.verificationScore)", source: "SampleAppView")
            }
        }
        
        // Store the result and mark verification as complete
        self.verificationResult = result
        self.isVerificationComplete = true
    }
    
    /// Verification result display helpers
    private var hasPersonalInfo: Bool {
        guard let result = verificationResult else { return false }
        return (result.fullName != nil || result.firstName != nil || result.lastName != nil)
    }
    
    private var hasDocumentMetrics: Bool {
        guard let result = verificationResult else { return false }
        return result.documentScore != nil || result.faceMatchScore > 0 || result.antiSpoofingFaceScore != nil
    }
    
    private var hasRiskInfo: Bool {
        guard let result = verificationResult else { return false }
        return (result.personScore != nil || result.personResult != nil || result.personRating != nil ||
         result.riskInformationScore != nil || result.riskInformationResult != nil || result.riskInformationRating != nil)
    }
    
    private var hasAdditionalInfo: Bool {
        guard let result = verificationResult else { return false }
        return result.requiresRecapture || result.recaptureType != nil
    }
    
    private var verificationIconName: String {
        guard let result = verificationResult else { return "questionmark.circle" }
        return result.isSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    private var verificationIconColor: Color {
        guard let result = verificationResult else { return textColor.opacity(0.5) }
        return result.isSuccessful ? Color(hex: "#4CAF50") : Color(hex: "#F44336")
    }
    
    private var verificationStatusTitle: String {
        guard let result = verificationResult else { return "Unknown" }
        return result.isSuccessful ? "Verification Successful" : "Verification Failed"
    }
    
    
    // MARK: - Authentication Flow
    
    /// Displays authentication result with response status
    private func authenticationResultsSection(_ result: String) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                // Result Header with Status Badge
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(languageManager.localize("sample_authentication_result"))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        HStack(spacing: 8) {
                            Image(systemName: authenticationIconName)
                                .font(.system(size: 20))
                                .foregroundColor(authenticationIconColor)
                            
                            Text(authenticationStatusTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(authenticationIconColor)
                        }
                    }
                    Spacer()
                }
                
                Divider()
                
                // Response Details
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: languageManager.localize("sample_response"), value: result, textColor: textColor)
                }
            }
        }
    }
    
    /// Handles the result from the authentication flow
    /// - Stores authenticated account number and full name
    /// - Updates UI with result status
    private func handleAuthenticationResult(_ result: Any, isSuccessful: Bool) {
        lastActionType = "authentication"
        let errorMessage = (result as? NSObject)?.value(forKey: "errorMessage") as? String
        
        logInfo("handleAuthenticationResult called with success: \(isSuccessful)", source: "SampleAppView")
        
        if isSuccessful {
            // Try to extract account info
            if let accountInfo = (result as? NSObject)?.value(forKey: "accountInfo") as? NSObject {
                if let accountNumber = accountInfo.value(forKey: "accountNumber") as? String {
                    UserDefaults.standard.set(accountNumber, forKey: "authenticationAccountNumber")
                    logInfo("Stored authenticated account number: \(accountNumber)", source: "SampleAppView")
                }
                
                if let fullName = accountInfo.value(forKey: "fullName") as? String {
                    UserDefaults.standard.set(fullName, forKey: "accountFullName")
                    logInfo("Stored authenticated full name: \(fullName)", source: "SampleAppView")
                }
            }
        } else {
            if let errorMessage = errorMessage {
                logWarning("Authentication failed: \(errorMessage)", source: "SampleAppView")
            } else {
                logWarning("Authentication failed", source: "SampleAppView")
            }
        }
        
        // Store the result and mark authentication as complete
        let statusString = isSuccessful ? "completed" : "failed"
        self.authenticationResult = statusString
        self.isAuthenticationComplete = true
    }
    
    /// Authentication result display helpers
    private var authenticationIconName: String {
        guard let result = authenticationResult else { return "questionmark.circle" }
        switch result.lowercased() {
        case "yes", "completed":
            return "checkmark.circle.fill"
        case "no", "cancelled":
            return "xmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    private var authenticationIconColor: Color {
        guard let result = authenticationResult else { return textColor.opacity(0.5) }
        switch result.lowercased() {
        case "yes", "completed":
            return Color(hex: "#4CAF50")
        case "no", "cancelled":
            return Color(hex: "#F44336")
        default:
            return Color(hex: "#FF9800")
        }
    }
    
    private var authenticationStatusTitle: String {
        guard let result = authenticationResult else { 
            return languageManager.localize("sample_status_unknown")
        }
        switch result.lowercased() {
        case "yes":
            return languageManager.localize("sample_authentication_success")
        case "no":
            return languageManager.localize("sample_authentication_failed")
        case "completed":
            return languageManager.localize("sample_authentication_complete")
        case "cancelled":
            return languageManager.localize("sample_authentication_cancelled")
        default:
            return languageManager.localize("sample_response_recorded")
        }
    }
    
    // MARK: - General Helpers & Theme Configuration
    
    /// Theme-aware color properties
    private var backgroundColor: Color {
        return viewModel.currentTheme.themeConfig.colorScheme.backgroundColor
    }
    
    private var textColor: Color {
        return viewModel.currentTheme.themeConfig.colorScheme.primaryColor
    }
    
    private var buttonTextColor: Color {
        return Color.white
    }
    
    private var primaryButtonColor: Color {
        return viewModel.currentTheme.themeConfig.colorScheme.primaryColor
    }
    
    private var secondaryButtonColor: Color {
        return viewModel.currentTheme.themeConfig.colorScheme.secondaryColor
    }
    
    /// Updates the SDK theme before launching a flow
    private func applySelectedSDKTheme() {
        let theme = viewModel.currentTheme.themeConfig
        ThemeManager.shared.setTheme(theme)
        logInfo("Applied SDK theme before flow launch: \(theme.brandName)", source: "SampleAppView")
    }
    
    /// Gets display name for language code
    private func getLanguageDisplayName(_ code: String) -> String {
        switch code {
        case "es-ES": return languageManager.localize("language_spanish")
        case "fr": return languageManager.localize("language_french")
        default: return languageManager.localize("language_english")
        }
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let label: String
    let value: String
    let textColor: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(textColor.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(textColor)
                .lineLimit(nil)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Supporting Views

struct CardView<Content: View>: View {
    let content: Content
    @EnvironmentObject var languageManager: LanguageManager
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ColorSwatchView: View {
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - ViewController Accessor

struct ViewControllerAccessor: UIViewControllerRepresentable {
    let onViewController: (UIViewController) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            // Find the presenting view controller
            if let presentingVC = viewController.presentingViewController {
                self.onViewController(presentingVC)
            } else {
                // Fallback: find root from window scene using modern API
                if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootVC = window.rootViewController {
                    self.onViewController(rootVC)
                }
            }
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update if needed
    }
}

// MARK: - Preview

struct SampleAppView_Previews: PreviewProvider {
    static var previews: some View {
        SampleAppView()
    }
}

