import Foundation

/// Current air quality at one location.
struct AirQualitySnapshot: Equatable, Sendable {
    let time: Date
    let usAQI: Int
    /// Fine particles, µg/m³.
    let pm25: Double?
    /// Coarse particles, µg/m³.
    let pm10: Double?

    var category: AQICategory { AQICategory(aqi: usAQI) }
}

/// One hour of the AQI forecast.
struct HourlyAQI: Identifiable, Equatable, Sendable {
    let time: Date
    let usAQI: Int

    var id: Date { time }
}

/// Everything the detail screen shows for a city.
struct AirQualityReport: Equatable, Sendable {
    let current: AirQualitySnapshot
    let hourly: [HourlyAQI]

    /// Forecast points starting from the current hour (one hour back, so the chart starts with "now").
    func upcoming(hours: Int) -> [HourlyAQI] {
        let start = current.time.addingTimeInterval(-3600)
        return Array(hourly.filter { $0.time >= start }.prefix(hours))
    }
}
