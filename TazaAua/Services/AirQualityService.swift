import Foundation

/// What view models depend on. A protocol so tests can pass a mock.
protocol AirQualityServicing: Sendable {
    func report(latitude: Double, longitude: Double) async throws -> AirQualityReport
}

/// Fetches air quality from the free Open-Meteo API (no API key needed).
struct OpenMeteoAirQualityService: AirQualityServicing {
    var client: any HTTPClient = URLSessionHTTPClient()

    func report(latitude: Double, longitude: Double) async throws -> AirQualityReport {
        var components = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "us_aqi,pm2_5,pm10"),
            URLQueryItem(name: "hourly", value: "us_aqi"),
            URLQueryItem(name: "forecast_days", value: "3"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]
        guard let url = components?.url else { throw APIError.invalidURL }

        let data = try await client.data(from: url)

        let dto: AirQualityResponseDTO
        do {
            dto = try JSONDecoder().decode(AirQualityResponseDTO.self, from: data)
        } catch {
            throw APIError.decoding
        }
        return try dto.toDomain()
    }
}
