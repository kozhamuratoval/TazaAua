import Foundation
import SwiftData

/// A city the user saved. Persisted on the device with SwiftData.
@Model
final class SavedCity {
    @Attribute(.unique) var cityID: Int
    var name: String
    var subtitle: String
    var latitude: Double
    var longitude: Double
    var addedAt: Date

    init(cityID: Int, name: String, subtitle: String, latitude: Double, longitude: Double, addedAt: Date = .now) {
        self.cityID = cityID
        self.name = name
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
        self.addedAt = addedAt
    }

    convenience init(city: City) {
        self.init(
            cityID: city.id,
            name: city.name,
            subtitle: city.subtitle,
            latitude: city.latitude,
            longitude: city.longitude
        )
    }
}
