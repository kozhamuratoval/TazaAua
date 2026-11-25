import Foundation

/// A city returned by the geocoding search.
struct City: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let region: String?
    let country: String?
    let latitude: Double
    let longitude: Double

    /// "Almaty, Kazakhstan"-style secondary line.
    var subtitle: String {
        [region, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty && $0 != name }
            .joined(separator: ", ")
    }

    /// Added on first launch so the app is useful right away.
    static let almaty = City(
        id: 1526384,
        name: "Almaty",
        region: nil,
        country: "Kazakhstan",
        latitude: 43.25,
        longitude: 76.91667
    )
}
