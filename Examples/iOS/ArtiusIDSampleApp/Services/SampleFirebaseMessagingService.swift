//
//  SampleFirebaseMessagingService.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 11/03/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import artiusid_sdk_ios
import FirebaseCore
import FirebaseMessaging

/// Sample App's Firebase Messaging Service
///
/// ARCHITECTURAL DECISION (matching Android):
/// - Sample app manages its own FCM tokens AND notifications
/// - SDK receives FCM token from sample app via updateFcmToken()
/// - Sample app has full control over notification display and handling
///
/// MATCHES ANDROID: SampleFirebaseMessagingService.kt
public class SampleFirebaseMessagingService: NSObject, MessagingDelegate {
    
    // MARK: - Singleton
    
    public static let shared = SampleFirebaseMessagingService()
    
    // MARK: - Constants
    
    private let TAG = "SampleFCMService"
    
    // MARK: - Properties
    
    private var currentToken: String?
    private let keychain = KeychainHelper.standard
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        logInfo("Sample Firebase Messaging Service created", source: "SampleFirebaseMessagingService")
        logInfo("Sample app controls all Firebase functionality", source: "SampleFirebaseMessagingService")
        
        // Set Firebase Messaging delegate
        Messaging.messaging().delegate = self
        logInfo("Firebase Messaging delegate set", source: "SampleFirebaseMessagingService")
    }
    
    // MARK: - MessagingDelegate
    
    /// Called when Firebase Messaging gets a new FCM token
    /// MATCHES ANDROID: onNewToken()
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        logInfo("New FCM token received from Firebase", source: "SampleFirebaseMessagingService")
        logDebug("FCM token: \(String(token.prefix(20)))...", source: "SampleFirebaseMessagingService")
        logDebug("FCM token length: \(token.count) characters", source: "SampleFirebaseMessagingService")
        
        handleNewToken(token)
    }
    
    // MARK: - Token Management
    
    /// Setup Firebase token management
    /// In a real implementation with Firebase SDK, this would initialize FirebaseMessaging
    /// For now, this uses APNs device token or generates a mock token
    public func setupTokenManagement() {
        logInfo("[\(TAG)] Setting up Firebase token management for sample app", source: "SampleFirebaseMessagingService")
        
        // Try to get existing token from keychain first
        let currentEnvironment = EnvironmentManager.shared.getCurrentEnvironment()
        if let existingToken = keychain.getFCMToken(for: currentEnvironment) {
            logDebug("[\(TAG)] Found existing FCM token in keychain: \(String(existingToken.prefix(20)))...", source: "SampleFirebaseMessagingService")
            currentToken = existingToken
            provideTokenToSDK(existingToken)
        } else {
            // If no token exists, we'll wait for APNs registration
            logInfo("[\(TAG)] No existing token, waiting for APNs registration", source: "SampleFirebaseMessagingService")
        }
    }
    
    /// Request APNs token (iOS native push notifications)
    /// This should be called from AppDelegate or SceneDelegate
    public func requestAPNsToken() {
        logInfo("[\(TAG)] Requesting APNs authorization", source: "SampleFirebaseMessagingService")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self else { return }
            if granted {
                logInfo("[\(self.TAG)] Notification permission granted", source: "SampleFirebaseMessagingService")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                logWarning("[\(self.TAG)] Notification permission denied", source: "SampleFirebaseMessagingService")
                if let error = error {
                    logError("[\(self.TAG)] Notification authorization error: \(error.localizedDescription)", source: "SampleFirebaseMessagingService")
                }
            }
        }
    }
    
    /// Handle new APNs device token
    /// This should be called from AppDelegate's didRegisterForRemoteNotificationsWithDeviceToken
    /// - Parameter deviceToken: APNs device token data
    public func didReceiveAPNsToken(_ deviceToken: Data) {
        // Convert APNs token to a hex string for APNs-only storage/debugging.
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        logInfo("New APNs token received by sample app", source: "SampleFirebaseMessagingService")
        logDebug("APNs token: \(String(token.prefix(20)))...", source: "SampleFirebaseMessagingService")
        logDebug("APNs token length: \(token.count) characters", source: "SampleFirebaseMessagingService")
        
        handleNewAPNsToken(token)

        // APNs token must never be sent as FCM token.
        // Ask Firebase for the mapped FCM registration token instead.
        Messaging.messaging().token { [weak self] fcmToken, error in
            guard let self = self else { return }

            if let error = error {
                logWarning("[\(self.TAG)] Unable to fetch FCM token after APNs registration: \(error.localizedDescription)", source: "SampleFirebaseMessagingService")
                return
            }

            guard let fcmToken = fcmToken, !fcmToken.isEmpty else {
                logInfo("[\(self.TAG)] FCM token not available yet after APNs registration", source: "SampleFirebaseMessagingService")
                return
            }

            logInfo("[\(self.TAG)] FCM token fetched after APNs registration", source: "SampleFirebaseMessagingService")
            self.handleNewToken(fcmToken)
        }
    }
    
    /// Handle new token (APNs or FCM)
    /// - Parameter token: Token string
    private func handleNewToken(_ token: String) {
        currentToken = token
        
        // Save token to sample app's secure storage (keychain)
        let currentEnvironment = EnvironmentManager.shared.getCurrentEnvironment()
        keychain.saveFCMToken(token, for: currentEnvironment)
        logInfo("[\(TAG)] FCM token saved to sample app storage for environment: \(currentEnvironment)", source: "SampleFirebaseMessagingService")
        
        // Provide token to SDK
        provideTokenToSDK(token)
    }
    
    /// Handle new APNs token
    /// - Parameter token: APNs token string
    private func handleNewAPNsToken(_ token: String) {
        // Save APNs token separately from FCM token
        let currentEnvironment = EnvironmentManager.shared.getCurrentEnvironment()
        keychain.saveAPNsToken(token, for: currentEnvironment)
        logInfo("[\(TAG)] APNs token saved to sample app storage for environment: \(currentEnvironment)", source: "SampleFirebaseMessagingService")

        // Do not provide APNs token to SDK. SDK payload must contain Firebase registration token only.
    }
    
    /// Provide token to SDK
    /// - Parameter token: FCM/APNs token
    private func provideTokenToSDK(_ token: String) {
        ArtiusIDSDK.shared.updateFCMToken(token)
        logInfo("[\(TAG)] FCM token provided to SDK via updateFCMToken()", source: "SampleFirebaseMessagingService")
    }
    
    // MARK: - Notification Handling
    
    /// Handle incoming notification
    /// This should be called from UNUserNotificationCenterDelegate
    /// - Parameters:
    ///   - userInfo: Notification payload
    ///   - completionHandler: Completion callback
    public func didReceiveNotification(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        logInfo("FCM message received by sample app", source: "SampleFirebaseMessagingService")
        logDebug("FCM data payload: \(userInfo)", source: "SampleFirebaseMessagingService")
        
        // Check if this is an approval notification
        let approvalTitle = userInfo["approvalTitle"] as? String
        let approvalDescription = userInfo["approvalDescription"] as? String
        let requestId = userInfo["requestId"] as? String
        
        if let title = approvalTitle, let description = approvalDescription {
            logInfo("[\(TAG)] Approval notification detected", source: "SampleFirebaseMessagingService")
            logDebug("[\(TAG)] Title: \(title)", source: "SampleFirebaseMessagingService")
            logDebug("[\(TAG)] Description: \(description)", source: "SampleFirebaseMessagingService")
            logDebug("[\(TAG)] Request ID: \(requestId ?? "N/A")", source: "SampleFirebaseMessagingService")
            
            // Parse requestId to Int
            let requestIdInt = requestId.flatMap { Int($0) }
            
            // Update AppNotificationState to trigger approval screen (matches Android)
            ArtiusID.AppNotificationState.shared.handleApprovalNotification(
                requestId: requestIdInt,
                title: title,
                description: description
            )
            
            logInfo("[\(TAG)] AppNotificationState updated - show approval screen", source: "SampleFirebaseMessagingService")
        }
        
        completionHandler()
    }
    
    // MARK: - Token Retrieval
    
    /// Get the current FCM token
    /// - Returns: Current token if available
    public func getCurrentToken() -> String? {
        return currentToken
    }
    
    /// Refresh token from keychain
    public func refreshToken() {
        let currentEnvironment = EnvironmentManager.shared.getCurrentEnvironment()
        if let token = keychain.getFCMToken(for: currentEnvironment) {
            currentToken = token
            provideTokenToSDK(token)
        }
    }
}

// MARK: - AppDelegate Integration Helper

extension SampleFirebaseMessagingService {
    
    /// Setup notification handling
    /// Call this from AppDelegate's application(_:didFinishLaunchingWithOptions:)
    public func setupNotificationHandling() {
        logInfo("[\(TAG)] Setting up notification handling", source: "SampleFirebaseMessagingService")
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        requestAPNsToken()
    }
}

// MARK: - Notification Delegate

/// Internal notification delegate to handle push notifications
private class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    
    // Handle notification when app is in foreground (just show the banner, don't navigate)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        logInfo("Notification received in foreground - showing banner only", source: "NotificationDelegate")
        // Just show the notification banner, don't trigger navigation
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap when user actually taps it (this is what triggers navigation)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        logInfo("User tapped notification - processing approval request", source: "NotificationDelegate")
        let userInfo = response.notification.request.content.userInfo
        SampleFirebaseMessagingService.shared.didReceiveNotification(userInfo: userInfo, completionHandler: completionHandler)
    }
}

