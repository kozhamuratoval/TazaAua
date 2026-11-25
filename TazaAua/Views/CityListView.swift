import SwiftUI
import SwiftData

/// Home screen: the user's saved cities with a live AQI badge for each.
struct CityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedCity.addedAt) private var cities: [SavedCity]
    @AppStorage("didSeedDefaultCity") private var didSeedDefaultCity = false
    @State private var isShowingSearch = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(cities) { city in
                    NavigationLink(value: city) {
                        CityRowView(city: city)
                    }
                }
                .onDelete(perform: deleteCities)
            }
            .navigationTitle("Taza Aua")
            .navigationDestination(for: SavedCity.self) { city in
                CityDetailView(city: city)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSearch = true
                    } label: {
                        Label("Add city", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if cities.isEmpty {
                    ContentUnavailableView(
                        "No cities yet",
                        systemImage: "aqi.medium",
                        description: Text("Tap + to add a city and check its air quality.")
                    )
                }
            }
            .sheet(isPresented: $isShowingSearch) {
                CitySearchView(savedCityIDs: Set(cities.map(\.cityID))) { city in
                    modelContext.insert(SavedCity(city: city))
                }
            }
            .task {
                seedDefaultCityIfNeeded()
            }
        }
    }

    private func deleteCities(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cities[index])
        }
    }

    /// Adds Almaty on the very first launch only, so deleting it later sticks.
    private func seedDefaultCityIfNeeded() {
        guard !didSeedDefaultCity else { return }
        if cities.isEmpty {
            modelContext.insert(SavedCity(city: .almaty))
        }
        didSeedDefaultCity = true
    }
}

/// One row in the list. Loads its own AQI so rows appear independently.
private struct CityRowView: View {
    let city: SavedCity
    @State private var viewModel: AirQualityViewModel

    init(city: SavedCity) {
        self.city = city
        _viewModel = State(initialValue: AirQualityViewModel(latitude: city.latitude, longitude: city.longitude))
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.headline)
                if !city.subtitle.isEmpty {
                    Text(city.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            switch viewModel.state {
            case .loaded(let report):
                AQIBadge(aqi: report.current.usAQI)
            case .failed:
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            case .idle, .loading:
                ProgressView()
            }
        }
        .padding(.vertical, 4)
        .task {
            if !viewModel.state.isLoaded {
                await viewModel.load()
            }
        }
    }
}

#Preview {
    CityListView()
        .modelContainer(for: SavedCity.self, inMemory: true)
}
