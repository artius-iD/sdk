//
//  SampleApp.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 10/29/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import SwiftUI
import Combine
import artiusid_sdk_ios
import FirebaseCore
import FirebaseMessaging

// MARK: - Type-Safe Notifications
extension Notification.Name {
    /// Posted when app language changes
    static let languageDidChange = Notification.Name("AppNotifications.languageDidChange")
    
    /// Posted when app theme changes
    static let themeDidChange = Notification.Name("AppNotifications.themeDidChange")
    
    /// Posted when environment changes
    static let environmentDidChange = Notification.Name("AppNotifications.environmentDidChange")
}

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            if currentLanguage != oldValue {
                AppPreferences.set(currentLanguage, forKey: .appLanguage)
                
                self.loadLanguageBundle()
                self.objectWillChange.send()
                artiusid_sdk_ios.LocalizationManager.shared.setLocale(Locale(identifier: currentLanguage))
                NotificationCenter.default.post(name: .languageDidChange, object: currentLanguage)
                
                logInfo("Language changed to \(currentLanguage)", source: "LanguageManager")
            }
        }
    }
    
    private var languageBundle: Bundle?
    let supportedLanguages = ["en", "es", "fr"]
    
    init() {
        if let savedLanguage = AppPreferences.get(forKey: .appLanguage) {
            self.currentLanguage = savedLanguage
        } else {
            let deviceLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"
            if supportedLanguages.contains(deviceLanguageCode) {
                self.currentLanguage = deviceLanguageCode
            } else {
                self.currentLanguage = "en"
            }
        }
        
        self.loadLanguageBundle()
        logInfo("LanguageManager initialized with language: \(self.currentLanguage)", source: "LanguageManager")
    }
    
    private func loadLanguageBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            languageBundle = Bundle(path: path)
        } else {
            languageBundle = nil
        }
    }
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    func localize(_ key: String, table: String = "Localizable") -> String {
        if let bundle = languageBundle {
            let localizedString = bundle.localizedString(forKey: key, value: key, table: table)
            if localizedString == key {
                return Bundle.main.localizedString(forKey: key, value: key, table: table)
            }
            return localizedString
        }
        return NSLocalizedString(key, tableName: table, bundle: Bundle.main, value: key, comment: "")
    }
    
    var currentLocale: Locale {
        return Locale(identifier: currentLanguage)
    }
}

// MARK: - Theme Manager
enum SimplifiedThemeListing: String, CaseIterable {
    case artiusID = "artiusID"
    case dark = "dark"
    case corporateBlue = "corporateBlue"
    
    var displayName: String {
        switch self {
        case .artiusID:
            return "artius.iD (Default)"
        case .dark:
            return "Dark Mode"
        case .corporateBlue:
            return "Corporate"
        }
    }
}

class AppThemeManager: ObservableObject {
    static let shared = AppThemeManager()
    
    @Published var currentTheme: SimplifiedThemeListing {
        didSet {
            if currentTheme != oldValue {
                AppPreferences.set(currentTheme.rawValue, forKey: .appTheme)
                
                self.objectWillChange.send()
                NotificationCenter.default.post(name: .themeDidChange, object: currentTheme)
                
                logInfo("Theme changed to \(currentTheme.displayName)", source: "AppThemeManager")
            }
        }
    }
    
    init() {
        if let savedThemeString = AppPreferences.get(forKey: .appTheme),
           let savedTheme = SimplifiedThemeListing(rawValue: savedThemeString) {
            self.currentTheme = savedTheme
        } else {
            self.currentTheme = .artiusID
        }
        
        logInfo("AppThemeManager initialized with theme: \(self.currentTheme.displayName)", source: "AppThemeManager")
    }
    
    func setTheme(_ theme: SimplifiedThemeListing) {
        currentTheme = theme
    }
}

@main
struct SampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var themeManager = AppThemeManager.shared
    
    init() {
        logInfo("SampleApp initializing", source: "SampleApp")
        
        // 🔥 CRITICAL: Initialize Firebase FIRST (matches Android)
        FirebaseApp.configure()
        logInfo("Firebase configured", source: "SampleApp")
        
        setupAppearance()
        Self.runDeferredConfiguration()
    }
    
    var body: some Scene {
        WindowGroup {
            SampleAppView()
                .environmentObject(languageManager)
                .environmentObject(themeManager)
                .id(languageManager.currentLanguage)
        }
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        // Configure global app appearance
        logInfo("Setting up app appearance", source: "SampleApp")
    }
    
    private static func runDeferredConfiguration() {
        configureSDK()
        configureLocalization()
    }
    
    private static func configureSDK() {
        // Initialize SDK managers early to prevent initialization issues
        logInfo("Initializing SDK managers", source: "SampleApp")
        
        // Force ColorManager initialization
        let _ = ColorManager.shared
        logInfo("ColorManager initialized", source: "SampleApp")
        
        // Force ThemeManager initialization
        let _ = ThemeManager.shared
        logInfo("ThemeManager initialized", source: "SampleApp")
        
        // Initialize EnvironmentManager
        let _ = EnvironmentManager.shared
        logInfo("EnvironmentManager initialized", source: "SampleApp")
        
        logInfo("SDK configuration ready", source: "SampleApp")
    }
    
    private static func configureLocalization() {
        // Sync app language with SDK's LocalizationManager
        let currentLanguage = LanguageManager.shared.currentLanguage
        artiusid_sdk_ios.LocalizationManager.shared.setLocale(Locale(identifier: currentLanguage))
        logInfo("Localization configured with language: \(currentLanguage)", source: "SampleApp")
    }
}

// MARK: - AppDelegate

/// AppDelegate for handling APNs registration and notifications
/// Matches Android's SampleApplication architecture
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logInfo("AppDelegate didFinishLaunchingWithOptions", source: "AppDelegate")
        
        // Setup notification handling (matches Android Firebase setup)
        SampleFirebaseMessagingService.shared.setupNotificationHandling()
        logInfo("Firebase/APNs notification handling setup complete", source: "AppDelegate")
        
        return true
    }
    
    // MARK: - APNs Token Registration
    
    /// Called when APNs registration succeeds
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        logInfo("APNs device token registered", source: "AppDelegate")
        
        // Pass token to Firebase Messaging (for FCM token mapping)
        Messaging.messaging().apnsToken = deviceToken
        
        // Pass token to messaging service (matches Android's onNewToken)
        SampleFirebaseMessagingService.shared.didReceiveAPNsToken(deviceToken)
    }
    
    /// Called when APNs registration fails
    func application(_ application: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logError("APNs registration failed: \(error.localizedDescription)", source: "AppDelegate")
    }
    
    // MARK: - Remote Notification Handling
    
    /// Called when a remote notification is received (including background/silent notifications)
    /// ✅ CRITICAL: This handles ALL remote notifications from APNs
    /// Matches Android: onMessageReceived() in SampleFirebaseMessagingService
    func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logInfo("Remote notification received", source: "AppDelegate")
        logDebug("App state: \(application.applicationState == .active ? "Foreground" : application.applicationState == .background ? "Background" : "Inactive")", source: "AppDelegate")
        logDebug("Payload: \(userInfo)", source: "AppDelegate")
        
        // Pass to Firebase Messaging for FCM handling
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Pass to our messaging service for processing
        SampleFirebaseMessagingService.shared.didReceiveNotification(userInfo: userInfo) {
            logInfo("Notification processed by SampleFirebaseMessagingService", source: "AppDelegate")
            completionHandler(.newData)
        }
    }
}

