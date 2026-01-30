import SwiftUI

struct PopoverContentView: View {
    var monitor: NetworkMonitor
    var settings = AppSettings.shared

    var body: some View {
        VStack(spacing: 12) {
            header

            VStack(spacing: 8) {
                if settings.showWiFiInfo {
                    WiFiInfoView(info: monitor.wifiInfo)
                }
                if settings.showSignalChart {
                    SignalChartView(
                        points: monitor.signalPoints,
                        currentRssi: monitor.wifiInfo.rssi,
                        minRssi: monitor.metrics.minRssi,
                        maxRssi: monitor.metrics.maxRssi,
                        avgRssi: monitor.metrics.avgRssi
                    )
                }
                if settings.showConnectionStatus {
                    NetworkHealthView(
                        status: monitor.networkStatus,
                        metrics: monitor.metrics,
                        latencyPoints: monitor.routerLatencyPoints
                    )
                }
                if settings.showSpeedTest {
                    SpeedTestView(
                        result: Binding(
                            get: { monitor.speedTestResult },
                            set: { _ in }
                        ),
                        isRunning: Binding(
                            get: { monitor.isRunningSpeedTest },
                            set: { _ in }
                        ),
                        onRunTest: {
                            Task {
                                await monitor.runSpeedTest()
                            }
                        }
                    )
                }
                if settings.showSuggestions {
                    SuggestionsView(suggestions: monitor.suggestions)
                }
            }
            .padding(.horizontal)

            footer
        }
        .padding(.top, 20)
        .padding(.bottom, 12)
        .frame(width: 320)
        .fixedSize(horizontal: false, vertical: true)
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
            Button(action: openPreferences) {
                Image(systemName: "gear")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            Button(action: quitApp) {
                Text("Quit")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private func openPreferences() {
        AppDelegate.shared.showPreferences()
    }

    private func quitApp() {
        NSApp.terminate(nil)
    }
}
