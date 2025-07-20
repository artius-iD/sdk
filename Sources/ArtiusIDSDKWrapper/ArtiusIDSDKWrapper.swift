// ArtiusIDSDKWrapper.swift
// This wrapper ensures Firebase dependencies are properly linked with the binary framework
// Created by Curtis Elswick on 07/07/2025

import Foundation
import FirebaseCore
import FirebaseMessaging
import OpenSSL

// Re-export the binary framework using the actual module name from XCFramework
@_exported import artiusid_sdk_ios

/// Wrapper class to ensure proper Firebase initialization for ArtiusID SDK
@objc public class ArtiusIDSDKWrapper: NSObject {
    
    /// Configure Firebase for ArtiusID SDK
    /// This should be called in your AppDelegate's didFinishLaunchingWithOptions
    @objc public static func configureFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    /// Initialize ArtiusID SDK with Firebase configuration
    /// Call this after configuring Firebase
    @objc public static func initialize() {
        configureFirebase()
        // Any additional SDK initialization can go here
    }
}

/// SDK Information and utilities
public struct ArtiusIDSDKInfo {
    public static let version = "1.0.16"
    public static let build = "Universal Binary (Device + Simulator)"
    public static let architecture = "Universal (arm64 + x86_64)"
    
    public static func printInfo() {
        print("ArtiusID SDK v\(version) (\(build)) - \(architecture)")
    }
}
