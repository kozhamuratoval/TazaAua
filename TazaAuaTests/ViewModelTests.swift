import Foundation
import Testing
@testable import TazaAua

// MARK: - Mocks

private struct MockAirQualityService: AirQualityServicing {
    let result: Result<AirQualityReport, APIError>

    func report(latitude: Double, longitude: Double) async throws -> AirQualityReport {
        try result.get()
    }
}

private struct MockCitySearchService: CitySearching {
    let cities: [City]

    func search(_ query: String) async throws -> [City] {
        cities
    }
}

private extension AirQualityReport {
    static let sample = AirQualityReport(
        current: AirQualitySnapshot(time: Date(timeIntervalSince1970: 0), usAQI: 42, pm25: 9.5, pm10: 14.0),
        hourly: []
    )
}

// MARK: - AirQualityViewModel

@MainActor
struct AirQualityViewModelTests {
    @Test func startsIdle() {
        let viewModel = AirQualityViewModel(latitude: 0, longitude: 0, service: MockAirQualityService(result: .success(.sample)))
        #expect(viewModel.state == .idle)
    }

    @Test func successfulLoadShowsReport() async {
        let viewModel = AirQualityViewModel(latitude: 0, longitude: 0, service: MockAirQualityService(result: .success(.sample)))

        await viewModel.load()

        #expect(viewModel.state == .loaded(.sample))
    }

    @Test func failedLoadShowsReadableMessage() async {
        let viewModel = AirQualityViewModel(latitude: 0, longitude: 0, service: MockAirQualityService(result: .failure(.offline)))

        await viewModel.load()

        #expect(viewModel.state == .failed(APIError.offline.errorDescription!))
    }
}

// MARK: - CitySearchViewModel

@MainActor
struct CitySearchViewModelTests {
    @Test func shortQueryDoesNotSearch() async {
        let viewModel = CitySearchViewModel(service: MockCitySearchService(cities: [.almaty]), debounce: .zero)
        viewModel.query = "A"

        await viewModel.search()

        #expect(viewModel.results.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func searchReturnsCities() async {
        let viewModel = CitySearchViewModel(service: MockCitySearchService(cities: [.almaty]), debounce: .zero)
        viewModel.query = "Alma"

        await viewModel.search()

        #expect(viewModel.results == [.almaty])
        #expect(viewModel.isSearching == false)
    }

    @Test func noResultsShowsMessage() async {
        let viewModel = CitySearchViewModel(service: MockCitySearchService(cities: []), debounce: .zero)
        viewModel.query = "Zzzz"

        await viewModel.search()

        #expect(viewModel.errorMessage != nil)
    }
}
