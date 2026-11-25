import Foundation
import Observation

/// Loads and holds the air quality report for one city.
/// Used by both the list row (badge) and the detail screen.
@MainActor
@Observable
final class AirQualityViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(AirQualityReport)
        case failed(String)

        var isLoaded: Bool {
            if case .loaded = self { return true }
            return false
        }
    }

    private(set) var state: State = .idle

    private let latitude: Double
    private let longitude: Double
    private let service: any AirQualityServicing

    init(latitude: Double, longitude: Double, service: any AirQualityServicing = OpenMeteoAirQualityService()) {
        self.latitude = latitude
        self.longitude = longitude
        self.service = service
    }

    func load() async {
        // On pull-to-refresh keep showing the old data instead of a spinner.
        if !state.isLoaded {
            state = .loading
        }

        do {
            let report = try await service.report(latitude: latitude, longitude: longitude)
            state = .loaded(report)
        } catch is CancellationError {
            // The view went away; nothing to show.
        } catch let error as URLError where error.code == .cancelled {
            // Same as above, thrown by URLSession.
        } catch {
            let message = (error as? LocalizedError)?.errorDescription
                ?? "Something went wrong. Please try again."
            state = .failed(message)
        }
    }
}
