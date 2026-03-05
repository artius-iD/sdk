import SwiftUI

public protocol SimplifiedTheme {
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var backgroundColor: Color { get }
    var surfaceColor: Color { get }
    
    var primaryText: Color { get }
    var secondaryText: Color { get }
    
    var cordRadius: CGFloat { get }
}

public enum SimplifiedThemeListing: String, CaseIterable {
    case artiusID = "artiusID"
    case dark = "dark"
    case corporateBlue = "corporateBlue"
    
    public var displayName: String {
        switch self {
        case .artiusID:
            return "artius.iD (Default)"
        case .dark:
            return "Dark Mode"
        case .corporateBlue:
            return "Corporate"
        }
    }
    
    public func theme() -> SimplifiedTheme {
        switch self {
        case .artiusID:
            return ArtiusIDDefaultTheme()
        case .dark:
            return DarkModeTheme()
        case .corporateBlue:
            return CorporateBlueTheme()
        }
    }
}

// MARK: - ArtiusID Default Theme

public struct ArtiusIDDefaultTheme: SimplifiedTheme {
    public var primaryColor: Color = Color(red: 0.0, green: 0.2, blue: 0.5) // Dark blue
    public var secondaryColor: Color = Color(red: 0.96, green: 0.51, blue: 0.13) // Orange (#F58220)
    public var backgroundColor: Color = Color(UIColor.systemBackground)
    public var surfaceColor: Color = Color(UIColor.secondarySystemBackground)
    
    public var primaryText: Color = Color(red: 0.13, green: 0.21, blue: 0.3) // Dark navy
    public var secondaryText: Color = Color(UIColor.secondaryLabel)
    
    public var cordRadius: CGFloat = 12
}

// MARK: - Dark Theme

public struct DarkModeTheme: SimplifiedTheme {
    public var primaryColor: Color = Color(red: 0.04, green: 0.52, blue: 1.0) // Bright blue
    public var secondaryColor: Color = Color(red: 1.0, green: 0.62, blue: 0.04) // Bright orange
    public var backgroundColor: Color = Color(UIColor.systemBackground)
    public var surfaceColor: Color = Color(UIColor.secondarySystemBackground)
    
    public var primaryText: Color = .white
    public var secondaryText: Color = Color(UIColor.secondaryLabel)
    
    public var cordRadius: CGFloat = 12
}

// MARK: - Corporate Blue Theme

public struct CorporateBlueTheme: SimplifiedTheme {
    public var primaryColor: Color = Color(red: 0.0, green: 0.29, blue: 0.61) // Professional blue
    public var secondaryColor: Color = Color(red: 0.25, green: 0.46, blue: 0.71) // Lighter blue
    public var backgroundColor: Color = Color(red: 0.95, green: 0.95, blue: 0.97)
    public var surfaceColor: Color = .white
    
    public var primaryText: Color = Color(red: 0.0, green: 0.29, blue: 0.61)
    public var secondaryText: Color = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    public var cordRadius: CGFloat = 16
}
