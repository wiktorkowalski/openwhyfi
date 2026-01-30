import SwiftUI

struct MetricsView: View {
    let metrics: NetworkMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                StatBox(
                    title: "Router Avg",
                    value: formatMs(metrics.routerAverage),
                    subtitle: "Jitter: \(formatMs(metrics.routerJitter))"
                )
                StatBox(
                    title: "Internet Avg",
                    value: formatMs(metrics.internetAverage),
                    subtitle: "Jitter: \(formatMs(metrics.internetJitter))"
                )
            }

            Text("\(metrics.latencyPoints.count) samples")
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func formatMs(_ value: Double?) -> String {
        guard let v = value else { return "—" }
        return String(format: "%.1f ms", v)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
            Text(subtitle)
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
