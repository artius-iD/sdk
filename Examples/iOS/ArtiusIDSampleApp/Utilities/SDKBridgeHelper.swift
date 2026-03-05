//
//  SDKBridgeHelper.swift
//  ArtiusID Sample App
//
//  SwiftUI helper to access UIKit bridge from SwiftUI views
//

import SwiftUI
import UIKit
import artiusid_sdk_ios

/// Helper to get the current root view controller for SDK bridge calls
struct ViewControllerHelper {
    static func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        // Navigate to the topmost view controller
        var topController = window.rootViewController
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        
        // If it's a navigation controller, get the visible view controller
        if let nav = topController as? UINavigationController {
            topController = nav.visibleViewController
        }
        
        return topController
    }
}

/// Wrapper view to inject view controller into environment
struct ViewControllerHolder: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

