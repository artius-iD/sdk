//
//  SampleAppSettingsView.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 10/29/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import SwiftUI
import UIKit
import artiusid_sdk_ios

/// Settings and configuration view for Sample App
///
/// Demonstrates common settings patterns for SDK-integrated apps:
/// - **Language Selection**: Switch between supported languages; automatically syncs to SDK
/// - **Environment Selection**: Switch between Sandbox/Development/Staging with certificate re-registration
/// - **Theme Customization**: Preview colors and select from predefined themes
/// - **Image Overrides**: Test custom icon/image scenarios
/// - **App Information**: Display SDK version, device info, certificates, and tokens (copy-to-clipboard)
///
/// **For SDK Users:** To add a new setting section:
/// 1. Create a computed property with MARK comment (e.g., `// MARK: Custom Section`)
/// 2. Return a Section with List rows bound to ViewModel properties
/// 3. Call `viewModel.updateSetting()` in button/picker actions
/// 4. SDK automatically reflects changes in flows (thanks to dependency injection)
///
struct SampleAppSettingsView: View {
    @ObservedObject var viewModel: SampleAppViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingInfoSheet = false
    @State private var isEnvironmentUnlocked = false
    @State private var copyToastMessage: String?
    
    var body: some View {
        NavigationView {
            List {
                // Language Section
                languageSection
                
                // Environment Section
                if isEnvironmentUnlocked {
                    environmentSection
                }
                
                // Theme Preview Section
                themePreviewSection
                
                // Theme Section
                themeSection
                
                // Image Overrides Section
                imageOverridesSection
            }
            .scrollContentBackground(.hidden)
            .background(themeBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(languageManager.localize("settings_title"))
                        .foregroundColor(themeTextColor)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 3.0) {
                            unlockEnvironmentSelection()
                        }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingInfoSheet = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(themePrimaryColor)
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 3.0)
                            .onEnded { _ in
                                unlockEnvironmentSelection()
                            }
                    )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localize("sample_done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(themeTextColor)
                    .disabled(viewModel.isUpdatingEnvironment)
                }
            }
            .sheet(isPresented: $showingInfoSheet) {
                infoSheetView
            }
            .overlay(
                Group {
                    if viewModel.isUpdatingEnvironment {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text(LocalizationManager.shared.string(forKey: "gen_processing"))
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding(30)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.7))
                            )
                        }
                    }
                }
            )
        }
    }
    
    // MARK: Settings Sections
    
    // MARK: Language Section
    
    private var languageSection: some View {
        Section {
            HStack {
                Text(languageManager.localize("settings_language"))
                    .foregroundColor(themeTextColor)
                
                Spacer()
                
                Picker("", selection: Binding(
                    get: { languageManager.currentLanguage },
                    set: { languageManager.setLanguage($0) }
                )) {
                    ForEach(languageManager.supportedLanguages, id: \.self) { language in
                        Text("\(getLanguageFlag(language)) \(getLanguageDisplayName(language))")
                            .tag(language)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(themePrimaryColor)
            }
        }
        .listRowBackground(themeListRowColor)
    }
    
    // MARK: Environment Section
    
    private var environmentSection: some View {
        Section {
            HStack {
                Text(languageManager.localize("settings_environment"))
                    .foregroundColor(themeTextColor)
                
                Spacer()
                
                Picker("", selection: Binding(
                    get: { viewModel.currentEnvironment },
                    set: { viewModel.updateEnvironment($0) }
                )) {
                    ForEach(EnvironmentConfig.Environment.allCases) { environment in
                        Text("\(environment.icon) \(environment.displayName)")
                            .tag(environment)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(themePrimaryColor)
                .disabled(viewModel.isUpdatingEnvironment)
            }
            
            Text(viewModel.currentEnvironment.description)
                .font(.caption)
                .foregroundColor(themeSecondaryTextColor)
        }
        .listRowBackground(themeListRowColor)
    }
    
    // MARK: Theme Preview Section
    
    private var themePreviewSection: some View {
        Section(header: Text(languageManager.localize("sample_theme_preview"))
            .foregroundColor(themeTextColor)) {
            HStack(spacing: 20) {
                // Primary Color Swatch
                ColorSwatchView(
                    label: languageManager.localize("sample_primary_color"),
                    color: viewModel.currentTheme.themeConfig.colorScheme.primaryColor
                )
                
                // Secondary Color Swatch
                ColorSwatchView(
                    label: languageManager.localize("sample_secondary_color"),
                    color: viewModel.currentTheme.themeConfig.colorScheme.secondaryColor
                )
                
                // Background Color Swatch
                ColorSwatchView(
                    label: languageManager.localize("sample_background_color"),
                    color: viewModel.currentTheme.themeConfig.colorScheme.backgroundColor
                )
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(themeListRowColor)
    }
    
    // MARK: Theme Section
    
    private var themeSection: some View {
        Section(header: Text(languageManager.localize("settings_theme"))
            .foregroundColor(themeTextColor)) {
            ForEach(ThemeOption.allCases) { theme in
                Button(action: {
                    viewModel.updateTheme(theme)
                }) {
                    HStack {
                        // Color preview
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: theme.themeConfig.colorScheme.primaryColorHex))
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(Color(hex: theme.themeConfig.colorScheme.secondaryColorHex))
                                .frame(width: 16, height: 16)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(theme.displayName)
                                .foregroundColor(themeTextColor)
                            Text(theme.description)
                                .font(.caption)
                                .foregroundColor(themeSecondaryTextColor)
                        }
                        
                        Spacer()
                        
                        if viewModel.currentTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(themePrimaryColor)
                        }
                    }
                }
            }
        }
        .listRowBackground(themeListRowColor)
    }
    
    // MARK: Image Overrides Section
    
    private var imageOverridesSection: some View {
        Section(header: Text(languageManager.localize("settings_imageOverrides"))
            .foregroundColor(themeTextColor)) {
            ForEach(ImageOverrideOption.allCases) { scenario in
                Button(action: {
                    viewModel.updateImageOverrideScenario(scenario)
                }) {
                    HStack(spacing: 12) {
                        // Visual indicator - customization count badge
                        VStack(alignment: .center, spacing: 2) {
                            Text("\(scenario.customizationCount)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(scenario.customizationCount > 0 ? themePrimaryColor : Color.gray.opacity(0.3))
                        )
                        
                        // Scenario info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(scenario.displayName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeTextColor)
                            Text(scenario.description)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(themeSecondaryTextColor)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        // Selection indicator
                        if viewModel.imageOverrideScenario == scenario {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(themePrimaryColor)
                                .font(.system(size: 20))
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            
            // Info box explaining image overrides
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themePrimaryColor)
                    
                    Text(LocalizationManager.shared.string(forKey: "settings_imageOverrides_description", fallback: "Image overrides allow you to customize icons, buttons, logos, and status indicators throughout the SDK flows."))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeSecondaryTextColor)
                        .lineLimit(nil)
                }
                .padding(.vertical, 2)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .listRowBackground(themeListRowColor)
    }
    
    // MARK: Theme Properties (For All Sections)
    
    private var themePrimaryColor: Color {
        viewModel.currentTheme.themeConfig.colorScheme.primaryColor
    }
    
    private var themeSecondaryColor: Color {
        viewModel.currentTheme.themeConfig.colorScheme.secondaryColor
    }
    
    private var themeBackgroundColor: Color {
        viewModel.currentTheme.themeConfig.colorScheme.backgroundColor
    }
    
    private var themeTextColor: Color {
        // Use primary color for text headings
        viewModel.currentTheme.themeConfig.colorScheme.primaryColor
    }
    
    private var themeSecondaryTextColor: Color {
        // Secondary text is more subtle - use primary color with opacity
        viewModel.currentTheme.themeConfig.colorScheme.primaryColor.opacity(0.6)
    }
    
    private var themeListRowColor: Color {
        // Slightly lighter than background for list rows
        let bgColor = viewModel.currentTheme.themeConfig.colorScheme.backgroundColor
        return bgColor.opacity(0.9)
    }
    
    // MARK: Settings Helpers

    private func unlockEnvironmentSelection() {
        if !isEnvironmentUnlocked {
            isEnvironmentUnlocked = true
        }
    }
    
    private func getLanguageDisplayName(_ code: String) -> String {
        switch code {
        case "es-ES": return languageManager.localize("language_spanish")
        case "fr": return languageManager.localize("language_french")
        default: return languageManager.localize("language_english")
        }
    }
    
    private func getLanguageFlag(_ code: String) -> String {
        switch code {
        case "es-ES": return "🇪🇸"
        case "fr": return "🇫🇷"
        default: return "🇺🇸"
        }
    }
    
    // MARK: Info Sheet Component
    
    private var infoSheetView: some View {
        NavigationView {
            List {
                Section(header: Text(LocalizationManager.shared.string(forKey: "settings_config_info", fallback: "Configuration Info")).foregroundColor(themePrimaryColor)) {
                    InfoRow(label: LocalizationManager.shared.string(forKey: "settings_client_id", fallback: "Client ID/Group ID"), value: "\(getClientId())/\(getClientGroupId())", textColor: themeTextColor)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        let value = getAccountNumber()
                        copyableTitle(label: LocalizationManager.shared.string(forKey: "settings_account_number", fallback: "Account Number"), value: value)
                        Text(value)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(themeSecondaryTextColor)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        let value = getFCMToken()
                        copyableTitle(label: LocalizationManager.shared.string(forKey: "settings_fcm_token", fallback: "FCM Token"), value: value)
                        Text(value)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(themeSecondaryTextColor)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        let value = getAPNsToken()
                        copyableTitle(label: LocalizationManager.shared.string(forKey: "settings_apn_token", fallback: "APN Token"), value: value)
                        Text(value)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(themeSecondaryTextColor)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        let value = getDeviceID()
                        copyableTitle(label: LocalizationManager.shared.string(forKey: "settings_device_id", fallback: "Device ID"), value: value)
                        Text(value)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(themeSecondaryTextColor)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text(LocalizationManager.shared.string(forKey: "settings_system_info", fallback: "System Information")).foregroundColor(themePrimaryColor)) {
                    InfoRow(label: LocalizationManager.shared.string(forKey: "settings_sdk_version", fallback: "SDK Version"), value: getSDKVersion(), textColor: themeTextColor)
                    InfoRow(label: LocalizationManager.shared.string(forKey: "settings_app_version", fallback: "App Version"), value: getAppVersion(), textColor: themeTextColor)
                }
                
                Section(header: Text(LocalizationManager.shared.string(forKey: "settings_certificate", fallback: "Certificate")).foregroundColor(themePrimaryColor)) {
                    InfoRow(label: LocalizationManager.shared.string(forKey: "settings_status", fallback: "Status"), value: getCertificateStatus(), textColor: themeTextColor)
                    if !getCertificateLoadedDate().isEmpty {
                        InfoRow(label: LocalizationManager.shared.string(forKey: "settings_loaded_date", fallback: "Loaded Date"), value: getCertificateLoadedDate(), textColor: themeTextColor)
                    }
                }
                
                Section(header: Text(LocalizationManager.shared.string(forKey: "settings_device", fallback: "Device")).foregroundColor(themePrimaryColor)) {
                    InfoRow(label: LocalizationManager.shared.string(forKey: "settings_model", fallback: "Model"), value: getDeviceModel(), textColor: themeTextColor)
                    InfoRow(label: LocalizationManager.shared.string(forKey: "settings_ios_version", fallback: "iOS Version"), value: getIOSVersion(), textColor: themeTextColor)
                }
            }
            .scrollContentBackground(.hidden)
            .background(themeBackgroundColor)
            .navigationTitle(LocalizationManager.shared.string(forKey: "settings_app_info", fallback: "App Information"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.shared.string(forKey: "sample_done", fallback: "Done")) {
                        showingInfoSheet = false
                    }
                    .foregroundColor(themePrimaryColor)
                }
            }
            .overlay(alignment: .bottom) {
                if let message = copyToastMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.75))
                        )
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: copyToastMessage)
        }
    }

    @ViewBuilder
    private func copyableTitle(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(themeTextColor)

            Spacer()

            Button(action: {
                copyValueToClipboard(label: label, value: value)
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themePrimaryColor)
            }
            .buttonStyle(.plain)
        }
    }

    private func copyValueToClipboard(label: String, value: String) {
        guard value != "Not Available" else {
            showCopyToast("No value to copy")
            return
        }

        UIPasteboard.general.string = value
        showCopyToast("Copied \(label)")
    }

    private func showCopyToast(_ message: String) {
        withAnimation {
            copyToastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation {
                copyToastMessage = nil
            }
        }
    }
    
    private func getClientId() -> Int {
        let config = EnvironmentConfig.configForEnvironment(viewModel.currentEnvironment)
        return config.clientId
    }
    
    private func getClientGroupId() -> Int {
        let config = EnvironmentConfig.configForEnvironment(viewModel.currentEnvironment)
        return config.clientGroupId
    }
    
    private func getAccountNumber() -> String {
        let currentEnv = viewModel.currentEnvironment.rawValue.lowercased()
        let sdkKeychain = KeychainHelper(service: "artiusid.dev")
        let accountNumberKey = "verification-\(currentEnv)"
        if let accountNumber = sdkKeychain[accountNumberKey], !accountNumber.isEmpty {
            return accountNumber
        }
        return "Not Available"
    }
    
    private func getFCMToken() -> String {
        let currentEnv = viewModel.currentEnvironment.rawValue
        let keychain = KeychainHelper.standard
        if let token = keychain.getFCMToken(for: currentEnv) {
            return token
        }
        return "Not Available"
    }
    
    private func getAPNsToken() -> String {
        let currentEnv = viewModel.currentEnvironment.rawValue
        let keychain = KeychainHelper.standard
        if let token = keychain.getAPNsToken(for: currentEnv) {
            return token
        }
        return "Not Available"
    }
    
    private func getDeviceID() -> String {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            return deviceID
        }
        return "Not Available"
    }
    
    private func getSDKVersion() -> String {
        return ArtiusIDSDK.version
    }
    
    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "Not Available"
    }
    
    private func getCertificateStatus() -> String {
        return CertificateManager.shared.hasCertificate() ? "Loaded" : "Not Loaded"
    }
    
    private func getCertificateLoadedDate() -> String {
        // Check if certificate file exists and get its modification date
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path,
           let files = try? fileManager.contentsOfDirectory(atPath: documentsPath) {
            if files.contains(where: { $0.contains("client-cert") }) {
                let certPath = documentsPath + "/client-cert-\(viewModel.currentEnvironment.rawValue.lowercased()).p12"
                if let attributes = try? fileManager.attributesOfItem(atPath: certPath),
                   let modDate = attributes[.modificationDate] as? Date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    return formatter.string(from: modDate)
                }
            }
        }
        return ""
    }
    
    private func getDeviceModel() -> String {
        return UIDevice.current.model
    }
    
    private func getIOSVersion() -> String {
        return UIDevice.current.systemVersion
    }
}

// MARK: - Preview

#if DEBUG
struct SampleAppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SampleAppSettingsView(viewModel: SampleAppViewModel())
            .environmentObject(LanguageManager.shared)
    }
}
#endif

