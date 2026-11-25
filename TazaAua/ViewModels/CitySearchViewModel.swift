import Foundation
import Observation

/// Drives the "Add city" search screen.
@MainActor
@Observable
final class CitySearchViewModel {
    var query = ""
    private(set) var results: [City] = []
    private(set) var isSearching = false
    private(set) var errorMessage: String?

    private let service: any CitySearching
    private let debounce: Duration

    init(service: any CitySearching = OpenMeteoCitySearchService(), debounce: Duration = .milliseconds(350)) {
        self.service = service
        self.debounce = debounce
    }

    /// Called from `.task(id: query)`, so SwiftUI cancels the previous call
    /// whenever the user types. The short sleep acts as a debounce.
    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            results = []
            errorMessage = nil
            isSearching = false
            return
        }

        isSearching = true
        do {
            try await Task.sleep(for: debounce)
            let cities = try await service.search(trimmed)
            results = cities
            errorMessage = cities.isEmpty ? "No cities found for “\(trimmed)”." : nil
            isSearching = false
        } catch is CancellationError {
            // A newer search replaced this one.
        } catch let error as URLError where error.code == .cancelled {
            // Same, thrown by URLSession.
        } catch {
            results = []
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Search failed. Please try again."
            isSearching = false
        }
    }
}
