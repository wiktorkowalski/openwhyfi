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
                    title: "Router",
                    value: formatMs(metrics.routerAverage),
                    jitter: metrics.routerJitter,
                    loss: metrics.routerLossPercent
                )
                StatBox(
                    title: "Internet",
                    value: formatMs(metrics.internetAverage),
                    jitter: metrics.internetJitter,
                    loss: metrics.internetLossPercent
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
    let jitter: Double?
    let loss: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
            HStack(spacing: 8) {
                Text("J: \(formatJitter)")
                    .foregroundStyle(jitterColor)
                Text("L: \(String(format: "%.0f%%", loss))")
                    .foregroundStyle(lossColor)
            }
            .font(.caption2)
            .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formatJitter: String {
        guard let j = jitter else { return "—" }
        return String(format: "%.1f", j)
    }

    private var jitterColor: Color {
        guard let j = jitter else { return .secondary }
        return colorFor(LatencyQuality.forJitter(j))
    }

    private var lossColor: Color {
        colorFor(LatencyQuality.forLoss(loss))
    }

    private func colorFor(_ quality: LatencyQuality) -> Color {
        switch quality {
        case .excellent, .good: return .green
        case .fair: return .orange
        case .poor: return .red
        }
    }
}
