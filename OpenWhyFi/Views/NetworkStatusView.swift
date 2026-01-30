import SwiftUI

struct NetworkStatusView: View {
    let status: NetworkStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection Status")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
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
                DNSStatusCard(result: status.dnsResult)
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
                .font(.callout)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(statusColor)

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
            return String(format: "%.0f ms", ms)
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

struct DNSStatusCard: View {
    let result: DNSResult

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text("DNS")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Text(latencyText)
                .font(.callout)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(statusColor)

            Text(result.server)
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
        guard result.success else { return "—" }
        return String(format: "%.0f ms", result.queryTime)
    }

    private var statusColor: Color {
        guard result.success else { return .secondary }
        switch LatencyQuality.forDNS(result.queryTime).color {
        case "green": return .green
        case "yellow": return .orange
        case "red": return .red
        default: return .secondary
        }
    }
}
