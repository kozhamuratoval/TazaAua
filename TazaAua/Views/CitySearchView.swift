import SwiftUI

/// Sheet for finding and adding a city.
struct CitySearchView: View {
    let savedCityIDs: Set<Int>
    let onAdd: (City) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CitySearchViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.results) { city in
                let isSaved = savedCityIDs.contains(city.id)
                Button {
                    onAdd(city)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(city.name)
                                .foregroundStyle(.primary)
                            if !city.subtitle.isEmpty {
                                Text(city.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if isSaved {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .disabled(isSaved)
            }
            .overlay { overlayContent }
            .navigationTitle("Add city")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a city"
            )
            .autocorrectionDisabled()
            .task(id: viewModel.query) {
                await viewModel.search()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        if viewModel.isSearching && viewModel.results.isEmpty {
            ProgressView()
        } else if let message = viewModel.errorMessage {
            ContentUnavailableView(message, systemImage: "magnifyingglass")
        } else if viewModel.results.isEmpty {
            ContentUnavailableView(
                "Find a city",
                systemImage: "magnifyingglass",
                description: Text("Type at least two letters, for example “Astana”.")
            )
        }
    }
}

#Preview {
    CitySearchView(savedCityIDs: []) { _ in }
}
