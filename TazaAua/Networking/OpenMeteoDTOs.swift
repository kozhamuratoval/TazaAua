import Foundation

// MARK: - Air quality

/// Raw response from https://air-quality-api.open-meteo.com/v1/air-quality.
/// DTOs mirror the JSON exactly; `toDomain()` turns them into app models.
struct AirQualityResponseDTO: Decodable {
    let utcOffsetSeconds: Int
    let current: Current
    let hourly: Hourly

    struct Current: Decodable {
        let time: String
        let usAQI: Double?
        let pm25: Double?
        let pm10: Double?

        enum CodingKeys: String, CodingKey {
            case time
            case usAQI = "us_aqi"
            case pm25 = "pm2_5"
            case pm10
        }
    }

    struct Hourly: Decodable {
        let time: [String]
        let usAQI: [Double?]

        enum CodingKeys: String, CodingKey {
            case time
            case usAQI = "us_aqi"
        }
    }

    enum CodingKeys: String, CodingKey {
        case utcOffsetSeconds = "utc_offset_seconds"
        case current
        case hourly
    }

    func toDomain() throws -> AirQualityReport {
        let parser = OpenMeteoDateParser(utcOffsetSeconds: utcOffsetSeconds)

        guard let currentTime = parser.date(from: current.time),
              let currentAQI = current.usAQI else {
            throw APIError.missingData
        }

        // Hours without a value come back as `null`; skip them.
        let points: [HourlyAQI] = zip(hourly.time, hourly.usAQI).compactMap { timeString, value in
            guard let value, let date = parser.date(from: timeString) else { return nil }
            return HourlyAQI(time: date, usAQI: Int(value.rounded()))
        }

        return AirQualityReport(
            current: AirQualitySnapshot(
                time: currentTime,
                usAQI: Int(currentAQI.rounded()),
                pm25: current.pm25,
                pm10: current.pm10
            ),
            hourly: points
        )
    }
}

/// Open-Meteo sends local times like "2026-11-24T23:00" plus the location's UTC offset.
struct OpenMeteoDateParser {
    private let formatter: DateFormatter

    init(utcOffsetSeconds: Int) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: utcOffsetSeconds)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        self.formatter = formatter
    }

    func date(from string: String) -> Date? {
        formatter.date(from: string)
    }
}

// MARK: - Geocoding

/// Raw response from https://geocoding-api.open-meteo.com/v1/search.
/// `results` is missing entirely when nothing matches.
struct GeocodingResponseDTO: Decodable {
    let results: [Result]?

    struct Result: Decodable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String?
        let admin1: String?
    }

    func toDomain() -> [City] {
        (results ?? []).map {
            City(
                id: $0.id,
                name: $0.name,
                region: $0.admin1,
                country: $0.country,
                latitude: $0.latitude,
                longitude: $0.longitude
            )
        }
    }
}
