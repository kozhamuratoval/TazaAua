import SwiftUI

/// The big card at the top of the detail screen.
struct AQIHeroCard: View {
    let snapshot: AirQualitySnapshot

    var body: some View {
        let category = snapshot.category
        VStack(spacing: 8) {
            Text("US AQI")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("\(snapshot.usAQI)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(category.color)
                .contentTransition(.numericText())
            Text(category.title)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(category.advice)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("Updated \(snapshot.time.formatted(date: .omitted, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(category.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(category.color.opacity(0.5), lineWidth: 2)
        }
    }
}

#Preview {
    AQIHeroCard(snapshot: AirQualitySnapshot(time: .now, usAQI: 156, pm25: 64.3, pm10: 81.0))
        .padding()
}
