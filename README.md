# Taza Aua — Air Quality for Your Cities

*Taza Aua* means "clean air" in Kazakh. It is a SwiftUI app that shows the current air quality and a 48-hour forecast for any city in the world, starting with Almaty.

<p float="left">
  <img src="Screenshots/list.png" width="250" />
  <img src="Screenshots/detail.png" width="250" />
  <img src="Screenshots/search.png" width="250" />
</p>


## Features

- **Saved cities**: your list of cities is stored on the device with SwiftData, each with a live, color-coded AQI badge.
- **City detail**: current US AQI with a health recommendation, PM2.5 and PM10 levels, pull to refresh.
- **48-hour forecast**: a Swift Charts bar chart with each hour colored by its AQI category.
- **City search**: debounced search powered by a geocoding API; already-saved cities are marked.
- **Clear states**: loading, empty and error screens (including offline) with a retry button.

## Tech stack

| Area | What is used |
|---|---|
| UI | SwiftUI, Swift Charts, `ContentUnavailableView` |
| Architecture | MVVM with the Observation framework (`@Observable`) |
| Concurrency | `async/await`, structured cancellation with `.task(id:)` |
| Networking | `URLSession`, `Codable` DTOs mapped to domain models |
| Persistence | SwiftData (`@Model`, `@Query`) |
| Testing | Swift Testing (`@Test`, `#expect`), mocked services |
| Minimum iOS | 17.0 |

## Architecture

```
TazaAua/
├── App/            App entry point and SwiftData container
├── Models/         Domain models (AirQualityReport, City, AQICategory) and the SwiftData model
├── Networking/     HTTPClient protocol, API errors, Open-Meteo DTOs and date parsing
├── Services/       AirQualityServicing and CitySearching protocols with Open-Meteo implementations
├── ViewModels/     @Observable view models with explicit loading / loaded / failed states
└── Views/          Screens and reusable components
TazaAuaTests/       Unit tests for mapping, AQI categories and view models
```

Data flows one way: **View → ViewModel → Service → HTTPClient**. Each layer depends on a protocol, not a concrete type, so view models are tested with mock services and no network.

## Running the project

1. Open `TazaAua.xcodeproj` in Xcode 16 or newer.
2. Choose an iPhone simulator and press **Run** (⌘R).
3. Run the tests with **⌘U**.

No API key is needed.

## Data

Air quality data comes from [Open-Meteo](https://open-meteo.com) (Air Quality API, based on Copernicus Atmosphere Monitoring Service CAMS ENSEMBLE forecasts). City search uses the Open-Meteo Geocoding API.

## Author

Liana Kozhamuratova · [LinkedIn](https://linkedin.com/in/liana-kozhamuratova) · [GitHub](https://github.com/kozhamuratoval)
