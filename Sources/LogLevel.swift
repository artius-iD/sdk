//
//  LogLevel.swift
//  artiusid-sdk-ios
//
//  Created by Curtis Elswick on 8/28/25.
//


// MARK: - LogLevel Enum
/// Log levels for SDK configuration
public enum LogLevel: String, CaseIterable, Identifiable {
    case verbose = "verbose"
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case none = "none"

    public var id: String { self.rawValue }
}