import SwiftUI

struct SpeedTestView: View {
    @Binding var result: SpeedTestResult?
    @Binding var isRunning: Bool
    let onRunTest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                        Text("Run")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isRunning)
            }

            if let result = result {
                HStack(spacing: 12) {
                    SpeedCard(
                        title: "Download",
                        value: String(format: "%.1f", result.downloadMbps),
                        unit: "Mbps",
                        icon: "arrow.down.circle.fill",
                        color: .blue
                    )
                    SpeedCard(
                        title: "Upload",
                        value: String(format: "%.1f", result.uploadMbps),
                        unit: "Mbps",
                        icon: "arrow.up.circle.fill",
                        color: .green
                    )
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Responsiveness")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text("\(result.responsiveness)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .monospacedDigit()
                            Text("RPM")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("(\(result.responsivenessQuality))")
                                .font(.caption2)
                                .foregroundStyle(responsivenessColor(result.responsivenessQuality))
                        }
                    }

                    if result.hasBufferbloat {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Bufferbloat detected")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                if let error = result.error {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            } else {
                Text("Tap Run to measure speed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
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
