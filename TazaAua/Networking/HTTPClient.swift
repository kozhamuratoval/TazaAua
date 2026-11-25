import Foundation

/// Errors shown to the user. `Equatable` so tests can compare them.
enum APIError: LocalizedError, Equatable {
    case invalidURL
    case badStatus(Int)
    case decoding
    case missingData
    case offline

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Something went wrong while building the request."
        case .badStatus(let code):
            "The server returned an error (\(code)). Please try again later."
        case .decoding, .missingData:
            "The server sent data we couldn't read."
        case .offline:
            "You appear to be offline. Check your internet connection."
        }
    }
}

/// Abstraction over the network so services can be tested without real requests.
protocol HTTPClient: Sendable {
    func data(from url: URL) async throws -> Data
}

struct URLSessionHTTPClient: HTTPClient {
    var session: URLSession = .shared

    func data(from url: URL) async throws -> Data {
        let result: (Data, URLResponse)
        do {
            result = try await session.data(from: url)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw APIError.offline
        }
        let (data, response) = result

        guard let http = response as? HTTPURLResponse else {
            throw APIError.badStatus(-1)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus(http.statusCode)
        }
        return data
    }
}
