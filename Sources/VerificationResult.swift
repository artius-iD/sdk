// VerificationResult.swift
// Shared result model for ArtiusID verification flows
// Move this file to Sources for SDK distribution

import Foundation

public struct VerificationResult {
    public let isSuccessful: Bool
    public let accountNumber: String?
    public let fullName: String?
    public let verificationScore: Double
    public let documentStatus: String?
    public let faceMatchScore: Int
    public let errorMessage: String?
    public let rawResponse: Any?
    
    public init(
        isSuccessful: Bool,
        accountNumber: String?,
        fullName: String?,
        verificationScore: Double,
        documentStatus: String? = nil,
        faceMatchScore: Int,
        errorMessage: String? = nil,
        rawResponse: Any? = nil
    ) {
        self.isSuccessful = isSuccessful
        self.accountNumber = accountNumber
        self.fullName = fullName
        self.verificationScore = verificationScore
        self.documentStatus = documentStatus
        self.faceMatchScore = faceMatchScore
        self.errorMessage = errorMessage
        self.rawResponse = rawResponse
    }
}
