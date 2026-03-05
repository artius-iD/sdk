//
//  SampleLocalizations.swift
//  ArtiusID Sample App
//
//  Created by Todd Bryant on 10/29/25.
//  Copyright © 2025 artius.iD, Inc. All rights reserved.
//

import Foundation
import artiusid_sdk_ios

/// Sample localization configurations demonstrating string customization
public struct SampleLocalizations {
    
    // MARK: - English (Brand Customized)
    
    /// Branded English strings
    public static let englishBranded: [String: String] = [
        LocalizationKeys.welcomeTitle: "Welcome to SecureID",
        LocalizationKeys.welcomeSubtitle: "Fast and secure verification in seconds",
        LocalizationKeys.getStartedButton: "Begin Verification",
        
        LocalizationKeys.documentSelectionTitle: "Choose Your Document",
        LocalizationKeys.selectDocumentType: "Select the type of ID you'd like to scan",
        
        LocalizationKeys.documentScanTitle: "Scan Your Document",
        LocalizationKeys.passportScanTitle: "Scan Your Passport",
        LocalizationKeys.stateIdScanTitle: "Scan Your State ID",
        
        LocalizationKeys.faceScanTitle: "Face Verification",
        LocalizationKeys.faceInstruction: "Position your face in the circle",
        LocalizationKeys.faceScanComplete: "Face captured successfully!",
        
        LocalizationKeys.processingTitle: "Verifying...",
        LocalizationKeys.processingMessage: "Please wait while we verify your identity",
        
        LocalizationKeys.verificationSuccessTitle: "Verification Complete!",
        LocalizationKeys.verificationSuccessMessage: "Your identity has been verified successfully",
        
        LocalizationKeys.continueButton: "Continue",
        LocalizationKeys.tryAgainButton: "Try Again",
        LocalizationKeys.cancelButton: "Cancel"
    ]
    
    // MARK: - Spanish (Español)
    
    /// Spanish translations
    public static let spanish: [String: String] = [
        LocalizationKeys.welcomeTitle: "Bienvenido a SecureID",
        LocalizationKeys.welcomeSubtitle: "Verificación rápida y segura en segundos",
        LocalizationKeys.getStartedButton: "Comenzar Verificación",
        
        LocalizationKeys.documentSelectionTitle: "Elige Tu Documento",
        LocalizationKeys.selectDocumentType: "Selecciona el tipo de identificación que deseas escanear",
        
        LocalizationKeys.documentScanTitle: "Escanea Tu Documento",
        LocalizationKeys.passportScanTitle: "Escanea Tu Pasaporte",
        LocalizationKeys.stateIdScanTitle: "Escanea Tu Identificación",
        
        LocalizationKeys.faceScanTitle: "Verificación Facial",
        LocalizationKeys.faceInstruction: "Coloca tu rostro en el círculo",
        LocalizationKeys.faceScanComplete: "¡Rostro capturado exitosamente!",
        
        LocalizationKeys.processingTitle: "Verificando...",
        LocalizationKeys.processingMessage: "Por favor espera mientras verificamos tu identidad",
        
        LocalizationKeys.verificationSuccessTitle: "¡Verificación Completa!",
        LocalizationKeys.verificationSuccessMessage: "Tu identidad ha sido verificada exitosamente",
        
        LocalizationKeys.continueButton: "Continuar",
        LocalizationKeys.tryAgainButton: "Intentar de Nuevo",
        LocalizationKeys.cancelButton: "Cancelar"
    ]
    
    // MARK: - French (Français)
    
    /// French translations
    public static let french: [String: String] = [
        LocalizationKeys.welcomeTitle: "Bienvenue à SecureID",
        LocalizationKeys.welcomeSubtitle: "Vérification rapide et sécurisée en quelques secondes",
        LocalizationKeys.getStartedButton: "Commencer la Vérification",
        
        LocalizationKeys.documentSelectionTitle: "Choisissez Votre Document",
        LocalizationKeys.selectDocumentType: "Sélectionnez le type d'identité que vous souhaitez scanner",
        
        LocalizationKeys.documentScanTitle: "Scannez Votre Document",
        LocalizationKeys.passportScanTitle: "Scannez Votre Passeport",
        LocalizationKeys.stateIdScanTitle: "Scannez Votre Carte d'Identité",
        
        LocalizationKeys.faceScanTitle: "Vérification Faciale",
        LocalizationKeys.faceInstruction: "Positionnez votre visage dans le cercle",
        LocalizationKeys.faceScanComplete: "Visage capturé avec succès!",
        
        LocalizationKeys.processingTitle: "Vérification...",
        LocalizationKeys.processingMessage: "Veuillez patienter pendant que nous vérifions votre identité",
        
        LocalizationKeys.verificationSuccessTitle: "Vérification Terminée!",
        LocalizationKeys.verificationSuccessMessage: "Votre identité a été vérifiée avec succès",
        
        LocalizationKeys.continueButton: "Continuer",
        LocalizationKeys.tryAgainButton: "Réessayer",
        LocalizationKeys.cancelButton: "Annuler"
    ]
    
    // MARK: - Corporate Style
    
    /// Professional corporate language
    public static let corporateStyle: [String: String] = [
        LocalizationKeys.welcomeTitle: "Identity Verification System",
        LocalizationKeys.welcomeSubtitle: "Secure enterprise-grade verification",
        LocalizationKeys.getStartedButton: "Initiate Verification Process",
        
        LocalizationKeys.documentScanTitle: "Document Authentication",
        LocalizationKeys.faceScanTitle: "Biometric Authentication",
        
        LocalizationKeys.processingTitle: "Processing Authentication",
        LocalizationKeys.processingMessage: "Authenticating your credentials...",
        
        LocalizationKeys.verificationSuccessTitle: "Authentication Successful",
        LocalizationKeys.verificationSuccessMessage: "Your credentials have been authenticated",
        
        LocalizationKeys.continueButton: "Proceed",
        LocalizationKeys.tryAgainButton: "Retry Authentication"
    ]
    
    // MARK: - Banking Style
    
    /// Banking/financial institution language
    public static let bankingStyle: [String: String] = [
        LocalizationKeys.welcomeTitle: "Secure Banking Verification",
        LocalizationKeys.welcomeSubtitle: "Protecting your financial identity",
        LocalizationKeys.getStartedButton: "Start Secure Verification",
        
        LocalizationKeys.documentScanTitle: "Verify Your Government ID",
        LocalizationKeys.faceScanTitle: "Biometric Security Check",
        
        LocalizationKeys.processingTitle: "Securing Your Identity",
        LocalizationKeys.processingMessage: "Your information is being securely processed",
        
        LocalizationKeys.verificationSuccessTitle: "Identity Secured",
        LocalizationKeys.verificationSuccessMessage: "Your banking identity has been verified",
        
        LocalizationKeys.continueButton: "Continue Securely",
        LocalizationKeys.tryAgainButton: "Verify Again"
    ]
    
    // MARK: - FinTech/Modern Style
    
    /// Modern fintech language
    public static let fintechStyle: [String: String] = [
        LocalizationKeys.welcomeTitle: "Quick Verification",
        LocalizationKeys.welcomeSubtitle: "Get verified in 60 seconds",
        LocalizationKeys.getStartedButton: "Let's Go",
        
        LocalizationKeys.documentScanTitle: "Snap Your ID",
        LocalizationKeys.faceScanTitle: "Quick Selfie",
        
        LocalizationKeys.processingTitle: "Almost There",
        LocalizationKeys.processingMessage: "Hang tight, we're verifying you",
        
        LocalizationKeys.verificationSuccessTitle: "You're All Set!",
        LocalizationKeys.verificationSuccessMessage: "Welcome aboard!",
        
        LocalizationKeys.continueButton: "Next",
        LocalizationKeys.tryAgainButton: "Retry"
    ]
    
    // MARK: - Casual/Friendly Style
    
    /// Friendly, casual language
    public static let casualStyle: [String: String] = [
        LocalizationKeys.welcomeTitle: "Hey There!",
        LocalizationKeys.welcomeSubtitle: "Let's verify your identity real quick",
        LocalizationKeys.getStartedButton: "Let's Start",
        
        LocalizationKeys.documentScanTitle: "Show Us Your ID",
        LocalizationKeys.faceScanTitle: "Time for a Selfie",
        
        LocalizationKeys.processingTitle: "Working on It",
        LocalizationKeys.processingMessage: "Give us a sec while we check everything",
        
        LocalizationKeys.verificationSuccessTitle: "Awesome!",
        LocalizationKeys.verificationSuccessMessage: "You're all verified!",
        
        LocalizationKeys.continueButton: "Continue",
        LocalizationKeys.tryAgainButton: "Try Again"
    ]
    
    // MARK: - Helper Methods
    
    /// Get localization for theme
    public static func localizationForTheme(_ theme: ThemeOption) -> [String: String] {
        switch theme {
        case .artiusDefault:
            return [:]  // Use SDK defaults
        case .corporateBlue:
            return corporateStyle
        case .darkTheme:
            return englishBranded
        case .bankingTheme:
            return bankingStyle
        case .fintechTheme:
            return fintechStyle
        }
    }
    
    /// Get localization for language
    public static func localizationForLanguage(_ language: Language) -> [String: String] {
        switch language {
        case .english:
            return englishBranded
        case .spanish:
            return spanish
        case .french:
            return french
        }
    }
}

// MARK: - Language Options

/// Supported languages
public enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }
    
    public var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        }
    }
    
    public var localizations: [String: String] {
        return SampleLocalizations.localizationForLanguage(self)
    }
}

// MARK: - Localization Style Options

/// Different text style options
public enum LocalizationStyle: String, CaseIterable, Identifiable {
    case standard = "standard"
    case branded = "branded"
    case corporate = "corporate"
    case banking = "banking"
    case fintech = "fintech"
    case casual = "casual"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .branded: return "Branded"
        case .corporate: return "Corporate"
        case .banking: return "Banking"
        case .fintech: return "FinTech"
        case .casual: return "Casual"
        }
    }
    
    public var description: String {
        switch self {
        case .standard:
            return "Default SDK text"
        case .branded:
            return "Custom branded text"
        case .corporate:
            return "Professional corporate language"
        case .banking:
            return "Banking/financial language"
        case .fintech:
            return "Modern fintech language"
        case .casual:
            return "Friendly, casual language"
        }
    }
    
    public var localizations: [String: String] {
        switch self {
        case .standard:
            return [:]
        case .branded:
            return SampleLocalizations.englishBranded
        case .corporate:
            return SampleLocalizations.corporateStyle
        case .banking:
            return SampleLocalizations.bankingStyle
        case .fintech:
            return SampleLocalizations.fintechStyle
        case .casual:
            return SampleLocalizations.casualStyle
        }
    }
}

