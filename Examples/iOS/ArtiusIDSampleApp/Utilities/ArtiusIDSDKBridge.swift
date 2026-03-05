//
//  ArtiusIDSDKBridge.swift
//  ArtiusID Sample App
//
//  UIKit bridge to launch SDK flows - matches Android's ArtiusIDSDK.startVerification() pattern
//  Created to replicate Android BridgeMainActivity functionality
//

import UIKit
import SwiftUI
import artiusid_sdk_ios

/// Bridge class matching Android's ArtiusIDSDK.startVerification/startAuthentication pattern
public class ArtiusIDSDKBridge {
    
    /// Shared singleton instance
    public static let shared = ArtiusIDSDKBridge()
    
    private init() {}
    
    /// Start verification flow - matches Android ArtiusIDSDK.startVerification()
    /// - Parameters:
    ///   - viewController: Presenting view controller
    ///   - configuration: Verification configuration
    ///   - completion: Completion handler with result
    public static func startVerification(
        from viewController: UIViewController,
        configuration: ArtiusIDVerificationView.Configuration,
        completion: @escaping (VerificationResult) -> Void
    ) {
        logInfo("ArtiusIDSDKBridge.startVerification called", source: "ArtiusIDSDKBridge")
        logDebug("Presenting from: \(type(of: viewController))", source: "ArtiusIDSDKBridge")
        
        let verificationView = ArtiusIDVerificationView(
            configuration: configuration,
            onCompletion: { result in
                logInfo("Verification completed in bridge", source: "ArtiusIDSDKBridge")
                viewController.dismiss(animated: true) {
                    completion(result)
                }
            },
            onCancel: {
                logInfo("Verification cancelled in bridge", source: "ArtiusIDSDKBridge")
                viewController.dismiss(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: verificationView)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .coverVertical
        
        logInfo("Presenting verification view controller", source: "ArtiusIDSDKBridge")
        viewController.present(hostingController, animated: true) {
            logInfo("Verification view controller presented successfully", source: "ArtiusIDSDKBridge")
        }
    }
    
    /// Start authentication flow - matches Android ArtiusIDSDK.startAuthentication()
    /// - Parameters:
    ///   - viewController: Presenting view controller
    ///   - configuration: Authentication configuration
    ///   - completion: Completion handler with result
    public static func startAuthentication(
        from viewController: UIViewController,
        configuration: ArtiusIDAuthenticationView.Configuration,
        completion: @escaping (ArtiusIDAuthenticationView.AuthenticationResult) -> Void
    ) {
        logInfo("ArtiusIDSDKBridge.startAuthentication called", source: "ArtiusIDSDKBridge")
        logDebug("Presenting from: \(type(of: viewController))", source: "ArtiusIDSDKBridge")
        
        let authenticationView = ArtiusIDAuthenticationView(
            configuration: configuration,
            onCompletion: { result in
                logInfo("Authentication completed in bridge", source: "ArtiusIDSDKBridge")
                viewController.dismiss(animated: true) {
                    completion(result)
                }
            },
            onCancel: {
                logInfo("Authentication cancelled in bridge", source: "ArtiusIDSDKBridge")
                viewController.dismiss(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: authenticationView)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .coverVertical
        
        logInfo("Presenting authentication view controller", source: "ArtiusIDSDKBridge")
        viewController.present(hostingController, animated: true) {
            logInfo("Authentication view controller presented successfully", source: "ArtiusIDSDKBridge")
        }
    }
}

/// SwiftUI helper to get root view controller
extension UIApplication {
    static var rootViewController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
    
    static func topViewController(from viewController: UIViewController? = rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(from: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(from: presented)
        }
        return viewController
    }
}

