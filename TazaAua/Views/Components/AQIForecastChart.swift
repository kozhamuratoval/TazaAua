import SwiftUI
import Charts

/// Bar chart of the hourly AQI forecast, each bar colored by its category.
struct AQIForecastChart: View {
    let points: [HourlyAQI]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next 48 hours")
                .font(.headline)

            if points.isEmpty {
                Text("No forecast available.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(points) { point in
                    BarMark(
                        x: .value("Time", point.time, unit: .hour),
                        y: .value("US AQI", point.usAQI)
                    )
                    .foregroundStyle(AQICategory(aqi: point.usAQI).color)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 12)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated).hour())
                    }
                }
                .frame(height: 180)
                .accessibilityLabel("Hourly air quality forecast")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let now = Date.now
    let points = (0..<48).map { hour in
        HourlyAQI(time: now.addingTimeInterval(Double(hour) * 3600), usAQI: 60 + (hour * 7) % 140)
    }
    return AQIForecastChart(points: points).padding()
}
