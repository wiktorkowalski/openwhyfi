import SwiftUI
import Charts

struct SparklineView: View {
    let points: [LatencyPoint]
    let title: String

    private var yAxisMax: Double {
        let allValues = points.compactMap { $0.routerLatency } + points.compactMap { $0.internetLatency }
        let maxVal = allValues.max() ?? 100
        // Round up to nice values: 50, 100, 150, 200, 300, 500
        if maxVal <= 50 { return 50 }
        if maxVal <= 100 { return 100 }
        if maxVal <= 150 { return 150 }
        if maxVal <= 200 { return 200 }
        if maxVal <= 300 { return 300 }
        return 500
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            if points.isEmpty {
                Text("Collecting data...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                        if let routerLatency = point.routerLatency {
                            LineMark(
                                x: .value("Time", index),
                                y: .value("Latency", routerLatency)
                            )
                            .foregroundStyle(by: .value("Type", "Router"))
                            .interpolationMethod(.catmullRom)
                        }

                        if let internetLatency = point.internetLatency {
                            LineMark(
                                x: .value("Time", index),
                                y: .value("Latency", internetLatency)
                            )
                            .foregroundStyle(by: .value("Type", "Internet"))
                            .interpolationMethod(.catmullRom)
                        }
                    }
                }
                .chartForegroundStyleScale([
                    "Router": Color.blue,
                    "Internet": Color.green
                ])
                .chartLegend(position: .bottom, spacing: 8)
                .chartXAxis(.hidden)
                .chartYScale(domain: 0...yAxisMax)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, yAxisMax / 2, yAxisMax]) { value in
                        AxisValueLabel {
                            if let ms = value.as(Double.self) {
                                Text("\(Int(ms))")
                                    .font(.caption2)
                                    .monospacedDigit()
                            }
                        }
                        AxisGridLine()
                    }
                }
                .frame(height: 80)
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }
}
