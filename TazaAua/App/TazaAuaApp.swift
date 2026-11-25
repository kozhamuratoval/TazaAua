import SwiftUI
import SwiftData

/// App entry point. Sets up the SwiftData container that stores the user's saved cities.
@main
struct TazaAuaApp: App {
    var body: some Scene {
        WindowGroup {
            CityListView()
        }
        .modelContainer(for: SavedCity.self)
    }
}
