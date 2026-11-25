import SwiftUI

/// Small colored pill with the AQI number, shown in the city list.
struct AQIBadge: View {
    let aqi: Int

    var body: some View {
        let category = AQICategory(aqi: aqi)
        Text("\(aqi)")
            .font(.headline.monospacedDigit())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(category.color, in: Capsule())
            .accessibilityLabel("Air quality index \(aqi), \(category.title)")
    }
}

#Preview {
    HStack {
        AQIBadge(aqi: 32)
        AQIBadge(aqi: 88)
        AQIBadge(aqi: 142)
        AQIBadge(aqi: 175)
        AQIBadge(aqi: 260)
    }
}
