import Foundation
import Testing
@testable import TazaAua

struct AirQualityDecodingTests {
    private let sampleJSON = """
    {
      "utc_offset_seconds": 18000,
      "current": { "time": "2026-11-24T23:00", "interval": 3600, "us_aqi": 153, "pm2_5": 61.2, "pm10": 80.4 },
      "hourly": {
        "time": ["2026-11-24T22:00", "2026-11-24T23:00", "2026-11-25T00:00"],
        "us_aqi": [150, 153, null]
      }
    }
    """

    @Test func decodesCurrentValues() throws {
        let dto = try JSONDecoder().decode(AirQualityResponseDTO.self, from: Data(sampleJSON.utf8))
        let report = try dto.toDomain()

        #expect(report.current.usAQI == 153)
        #expect(report.current.category == .unhealthy)
        #expect(report.current.pm25 == 61.2)
        #expect(report.current.pm10 == 80.4)
    }

    @Test func skipsHoursWithoutData() throws {
        let dto = try JSONDecoder().decode(AirQualityResponseDTO.self, from: Data(sampleJSON.utf8))
        let report = try dto.toDomain()

        #expect(report.hourly.map(\.usAQI) == [150, 153])
    }

    @Test func usesTheLocationsUTCOffset() throws {
        let dto = try JSONDecoder().decode(AirQualityResponseDTO.self, from: Data(sampleJSON.utf8))
        let report = try dto.toDomain()

        // 23:00 in Almaty (UTC+5) is 18:00 UTC.
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        #expect(utcCalendar.component(.hour, from: report.current.time) == 18)
    }

    @Test func missingCurrentAQIThrows() throws {
        let json = """
        { "utc_offset_seconds": 0,
          "current": { "time": "2026-11-24T23:00", "us_aqi": null },
          "hourly": { "time": [], "us_aqi": [] } }
        """
        let dto = try JSONDecoder().decode(AirQualityResponseDTO.self, from: Data(json.utf8))

        #expect(throws: APIError.missingData) {
            try dto.toDomain()
        }
    }

    @Test func emptyGeocodingResponseGivesNoCities() throws {
        let dto = try JSONDecoder().decode(GeocodingResponseDTO.self, from: Data("{}".utf8))
        #expect(dto.toDomain().isEmpty)
    }

    @Test func upcomingStartsAtCurrentHour() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let hourly = (-3...5).map { offset in
            HourlyAQI(time: now.addingTimeInterval(Double(offset) * 3600), usAQI: 50)
        }
        let report = AirQualityReport(
            current: AirQualitySnapshot(time: now, usAQI: 50, pm25: nil, pm10: nil),
            hourly: hourly
        )

        let upcoming = report.upcoming(hours: 3)

        #expect(upcoming.count == 3)
        #expect(upcoming.first?.time == now.addingTimeInterval(-3600))
    }
}
