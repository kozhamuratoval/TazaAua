import Foundation

protocol CitySearching: Sendable {
    func search(_ query: String) async throws -> [City]
}

/// City search backed by the Open-Meteo geocoding API.
struct OpenMeteoCitySearchService: CitySearching {
    var client: any HTTPClient = URLSessionHTTPClient()

    func search(_ query: String) async throws -> [City] {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json"),
        ]
        guard let url = components?.url else { throw APIError.invalidURL }

        let data = try await client.data(from: url)
        do {
            return try JSONDecoder().decode(GeocodingResponseDTO.self, from: data).toDomain()
        } catch {
            throw APIError.decoding
        }
    }
}
