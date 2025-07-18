import Foundation

@_exported import ArtiusIDSDK

public struct ArtiusIDSDKInfo {
    public static let version = "10.0.11"
    public static let build = "GitHub Distribution"
    
    public static func printInfo() {
        print("ArtiusID SDK v\(version)")
    }
}
