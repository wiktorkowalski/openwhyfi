import SwiftUI

struct SpeedTestView: View {
    @Binding var result: SpeedTestResult?
    @Binding var isRunning: Bool
    let onRunTest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Speed Test")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: onRunTest) {
                    if isRunning {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isRunning)
            }

            if let result = result {
                HStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(.blue)
                        Text(String(format: "%.0f", result.downloadMbps))
                            .fontWeight(.semibold)
                        Text("Mbps")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(.green)
                        Text(String(format: "%.0f", result.uploadMbps))
                            .fontWeight(.semibold)
                        Text("Mbps")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    HStack(spacing: 4) {
                        Text("\(result.responsiveness)")
                            .fontWeight(.semibold)
                        Text("RPM")
                    }
                    .foregroundStyle(responsivenessColor(result.responsivenessQuality))
                    .frame(maxWidth: .infinity)
                }
                .font(.caption)
                .monospacedDigit()

                if result.hasBufferbloat {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Bufferbloat detected")
                    }
                    .font(.caption2)
                    .foregroundStyle(.orange)
                }

                if let error = result.error {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func responsivenessColor(_ quality: String) -> Color {
        switch quality {
        case "High": return .green
        case "Medium": return .orange
        default: return .red
        }
    }
}

struct SpeedCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
