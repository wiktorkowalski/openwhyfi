import SwiftUI
import Charts

struct SignalChartView: View {
    let points: [SignalPoint]
    let currentRssi: Int
    let minRssi: Int?
    let maxRssi: Int?
    let avgRssi: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Signal Strength")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(currentRssi) dBm")
                    .font(.caption)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .foregroundStyle(signalColor)
            }

            Chart(points) { point in
                AreaMark(
                    x: .value("Time", point.timestamp),
                    yStart: .value("Min", -90),
                    yEnd: .value("RSSI", point.rssi)
                )
                .foregroundStyle(areaGradient)
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("RSSI", point.rssi)
                )
                .foregroundStyle(signalColor)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: -90 ... -30)
            .chartYAxis {
                AxisMarks(position: .leading, values: [-90, -70, -50, -30]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.3))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 100)

            HStack(spacing: 16) {
                StatLabel(title: "Min", value: minRssi.map { "\($0)" } ?? "—")
                StatLabel(title: "Max", value: maxRssi.map { "\($0)" } ?? "—")
                StatLabel(title: "Avg", value: avgRssi.map { String(format: "%.0f", $0) } ?? "—")
                Spacer()
                Text("\(points.count) samples")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }

    private var signalColor: Color {
        switch currentRssi {
        case -50...0: return .green
        case -60...(-51): return .green
        case -70...(-61): return .orange
        default: return .red
        }
    }

    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [.green.opacity(0.4), .yellow.opacity(0.3), .orange.opacity(0.2), .red.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct StatLabel: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}
