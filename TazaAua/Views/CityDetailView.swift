import SwiftUI

/// Detail screen: current AQI, pollutants and the 48-hour forecast.
struct CityDetailView: View {
    let city: SavedCity
    @State private var viewModel: AirQualityViewModel

    init(city: SavedCity) {
        self.city = city
        _viewModel = State(initialValue: AirQualityViewModel(latitude: city.latitude, longitude: city.longitude))
    }

    var body: some View {
        ScrollView {
            content
                .padding()
        }
        .navigationTitle(city.name)
        .refreshable {
            await viewModel.load()
        }
        .task {
            if !viewModel.state.isLoaded {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading air quality…")
                .frame(maxWidth: .infinity, minHeight: 320)

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load data", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(minHeight: 320)

        case .loaded(let report):
            VStack(spacing: 16) {
                AQIHeroCard(snapshot: report.current)

                HStack(spacing: 12) {
                    PollutantTile(name: "PM2.5", value: report.current.pm25)
                    PollutantTile(name: "PM10", value: report.current.pm10)
                }

                AQIForecastChart(points: report.upcoming(hours: 48))

                // Attribution required by Open-Meteo / CAMS terms.
                Link(destination: URL(string: "https://open-meteo.com")!) {
                    Text("Air quality data: Open-Meteo.com · CAMS ENSEMBLE")
                        .font(.footnote)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
