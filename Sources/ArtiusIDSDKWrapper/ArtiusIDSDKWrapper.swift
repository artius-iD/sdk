import Foundation

@_exported import ArtiusIDSDK

public struct ArtiusIDSDKInfo {
    public static let version = "1.0.8"
    public static let build = "GitHub Distribution"
    
    public static func printInfo() {
        print("ArtiusID SDK v\(version)")
    }
}
