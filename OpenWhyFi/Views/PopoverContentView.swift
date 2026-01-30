import SwiftUI

struct PopoverContentView: View {
    var monitor: NetworkMonitor

    var body: some View {
        VStack(spacing: 12) {
            header

            VStack(spacing: 12) {
                WiFiInfoView(info: monitor.wifiInfo)
                NetworkStatusView(status: monitor.networkStatus)
                SparklineView(
                    points: monitor.routerLatencyPoints,
                    title: "Latency History"
                )
                MetricsView(metrics: monitor.metrics)
            }
            .padding(.horizontal)

            Spacer()

            footer
        }
        .padding(.top, 20)
        .padding(.bottom, 12)
        .frame(width: 320, height: 580)
    }

    private var header: some View {
        HStack {
            Text("OpenWhyFi")
                .font(.headline)
            Spacer()
            Button {
                Task {
                    await monitor.refresh()
                }
            } label: {
                if monitor.isRefreshing {
                    ProgressView()
                        .scaleEffect(0.6)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .buttonStyle(.borderless)
            .frame(width: 20, height: 20)
        }
        .padding(.horizontal)
    }

    private var footer: some View {
        HStack {
            Text(monitor.lastUpdate != nil ? "Updated \(monitor.lastUpdate!.formatted(.relative(presentation: .named)))" : " ")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}
