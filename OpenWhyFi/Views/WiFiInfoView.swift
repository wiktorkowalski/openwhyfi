import SwiftUI

struct WiFiInfoView: View {
    let info: WiFiInfo

    var body: some View {
        HStack {
            Image(systemName: wifiIcon)
                .font(.title3)
                .foregroundStyle(signalColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(info.ssid)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    Text("\(info.rssi) dBm")
                        .foregroundStyle(signalColor)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("Ch \(info.channel)")
                    if info.transmitRate > 0 {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("\(Int(info.transmitRate)) Mbps")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Text(info.band.rawValue)
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }

    private var quality: SignalQuality {
        SignalQuality.fromSettings(rssi: info.rssi)
    }

    private var wifiIcon: String {
        switch quality {
        case .excellent, .good: return "wifi"
        case .fair: return "wifi"
        case .poor: return "wifi.exclamationmark"
        case .none: return "wifi.slash"
        }
    }

    private var signalColor: Color {
        switch quality.color {
        case "green": return .green
        case "yellow": return .orange
        case "red": return .red
        default: return .secondary
        }
    }

    private var snrQuality: String {
        switch info.snr {
        case 25...: return "green"
        case 15..<25: return "yellow"
        default: return "red"
        }
    }
}

struct MetricBadge: View {
    let label: String
    let value: String
    let quality: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(qualityColor.opacity(0.15))
        .cornerRadius(6)
    }

    private var qualityColor: Color {
        switch quality {
        case "green": return .green
        case "yellow": return .orange
        case "red": return .red
        case "blue": return .blue
        default: return .secondary
        }
    }
}
