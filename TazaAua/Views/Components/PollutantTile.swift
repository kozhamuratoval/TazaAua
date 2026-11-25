import SwiftUI

/// Shows one pollutant concentration, e.g. PM2.5.
struct PollutantTile: View {
    let name: String
    let value: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? "—")
                .font(.title2.weight(.bold))
            Text("µg/m³")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HStack {
        PollutantTile(name: "PM2.5", value: 41.27)
        PollutantTile(name: "PM10", value: nil)
    }
    .padding()
}
