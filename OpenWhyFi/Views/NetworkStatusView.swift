import SwiftUI

struct NetworkStatusView: View {
    let status: NetworkStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection Status")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                PingStatusCard(
                    title: "Router",
                    subtitle: status.gatewayIP ?? "—",
                    pingStatus: status.routerPing,
                    qualityFor: LatencyQuality.forRouter
                )
                PingStatusCard(
                    title: "Internet",
                    subtitle: PingService.internetTarget,
                    pingStatus: status.internetPing,
                    qualityFor: LatencyQuality.forInternet
                )
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct PingStatusCard: View {
    let title: String
    let subtitle: String
    let pingStatus: PingStatus
    let qualityFor: (Double) -> LatencyQuality

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Text(latencyText)
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(statusColor)
                .frame(minWidth: 80)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }

    private var latencyText: String {
        switch pingStatus {
        case .success(let ms):
            return String(format: "%.1f ms", ms)
        case .timeout:
            return "Timeout"
        case .error:
            return "Error"
        case .unknown:
            return "—"
        }
    }

    private var statusColor: Color {
        switch pingStatus {
        case .success(let ms):
            switch qualityFor(ms).color {
            case "green": return .green
            case "yellow": return .orange
            case "red": return .red
            default: return .secondary
            }
        case .timeout, .error:
            return .red
        case .unknown:
            return .secondary
        }
    }
}
