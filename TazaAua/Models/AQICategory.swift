import Foundation

/// US EPA Air Quality Index categories.
/// Kept free of SwiftUI so it can be unit-tested; colors live in `AQICategory+Color.swift`.
enum AQICategory: CaseIterable, Equatable, Sendable {
    case good
    case moderate
    case unhealthyForSensitiveGroups
    case unhealthy
    case veryUnhealthy
    case hazardous

    init(aqi: Int) {
        switch aqi {
        case ..<51: self = .good
        case 51...100: self = .moderate
        case 101...150: self = .unhealthyForSensitiveGroups
        case 151...200: self = .unhealthy
        case 201...300: self = .veryUnhealthy
        default: self = .hazardous
        }
    }

    var title: String {
        switch self {
        case .good: "Good"
        case .moderate: "Moderate"
        case .unhealthyForSensitiveGroups: "Unhealthy for Sensitive Groups"
        case .unhealthy: "Unhealthy"
        case .veryUnhealthy: "Very Unhealthy"
        case .hazardous: "Hazardous"
        }
    }

    var advice: String {
        switch self {
        case .good:
            "Air quality is great. Enjoy time outside."
        case .moderate:
            "Acceptable for most people. Very sensitive people should limit long outdoor exertion."
        case .unhealthyForSensitiveGroups:
            "Children, older adults and people with asthma should reduce outdoor activity."
        case .unhealthy:
            "Everyone should limit time outside. Consider wearing a mask."
        case .veryUnhealthy:
            "Avoid outdoor activity. Keep windows closed and use an air purifier if you have one."
        case .hazardous:
            "Health alert: stay indoors and avoid all outdoor activity."
        }
    }
}
