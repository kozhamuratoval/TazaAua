import SwiftUI

extension AQICategory {
    /// Standard US AQI colors.
    var color: Color {
        switch self {
        case .good: Color(red: 0.20, green: 0.72, blue: 0.35)
        case .moderate: Color(red: 0.95, green: 0.77, blue: 0.06)
        case .unhealthyForSensitiveGroups: Color(red: 0.98, green: 0.55, blue: 0.10)
        case .unhealthy: Color(red: 0.90, green: 0.22, blue: 0.21)
        case .veryUnhealthy: Color(red: 0.56, green: 0.27, blue: 0.68)
        case .hazardous: Color(red: 0.49, green: 0.10, blue: 0.14)
        }
    }
}
