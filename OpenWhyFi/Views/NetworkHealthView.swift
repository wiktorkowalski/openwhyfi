import SwiftUI
import Charts

struct NetworkHealthView: View {
    let status: NetworkStatus
    let metrics: NetworkMetrics
    let latencyPoints: [LatencyPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Network")
                .font(.subheadline)
                .fontWeight(.semibold)

            // Compact status row
            HStack(spacing: 8) {
                StatusPill(
                    label: "Router",
                    ping: status.routerPing,
                    jitter: metrics.routerJitter,
                    loss: metrics.routerLossPercent
                )
                StatusPill(
                    label: "Internet",
                    ping: status.internetPing,
                    jitter: metrics.internetJitter,
                    loss: metrics.internetLossPercent
                )
                StatusPill(
                    label: "DNS",
                    jitter: metrics.dnsJitter,
                    loss: metrics.dnsLossPercent,
                    dns: status.dnsResult
                )
            }

            // Compact latency chart with legend
            if !latencyPoints.isEmpty {
                VStack(spacing: 4) {
                    Chart(latencyPoints) { point in
                        if let router = point.routerLatency {
                            LineMark(
                                x: .value("Time", point.timestamp),
                                y: .value("Latency", router),
                                series: .value("Type", "Router")
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                        }
                        if let internet = point.internetLatency {
                            LineMark(
                                x: .value("Time", point.timestamp),
                                y: .value("Latency", internet),
                                series: .value("Type", "Internet")
                            )
                            .foregroundStyle(.green)
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                        }
                    }
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    .chartLegend(.hidden)
                    .frame(height: 35)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Circle().fill(.blue).frame(width: 6, height: 6)
                            Text("Router")
                        }
                        HStack(spacing: 4) {
                            Circle().fill(.green).frame(width: 6, height: 6)
                            Text("Internet")
                        }
                        Spacer()
                        Text("\(latencyPoints.count) samples")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct StatusPill: View {
    let label: String
    var ping: PingStatus?
    var jitter: Double?
    var loss: Double?
    var dns: DNSResult?

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(.caption2)
            }

            Text(valueText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(statusColor)
                .monospacedDigit()

            if let j = jitter {
                Text("J:\(String(format: "%.0f", j)) L:\(String(format: "%.0f", loss ?? 0))%")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.1))
        .cornerRadius(6)
    }

    private var valueText: String {
        if let dns = dns {
            return dns.success ? "\(Int(dns.queryTime))ms" : "—"
        }
        if let ping = ping {
            switch ping {
            case .success(let ms): return "\(Int(ms))ms"
            case .timeout: return "timeout"
            case .error: return "error"
            case .unknown: return "—"
            }
        }
        return "—"
    }

    private var statusColor: Color {
        let s = AppSettings.shared
        if let dns = dns {
            if !dns.success { return .red }
            return dns.queryTime < s.dnsGood ? .green : (dns.queryTime < s.dnsFair ? .orange : .red)
        }
        if let ping = ping {
            switch ping {
            case .success(let ms):
                if label == "Router" {
                    return ms < s.routerGood ? .green : (ms < s.routerFair ? .orange : .red)
                } else {
                    return ms < s.internetGood ? .green : (ms < s.internetFair ? .orange : .red)
                }
            case .timeout, .error: return .red
            case .unknown: return .secondary
            }
        }
        return .secondary
    }
}
