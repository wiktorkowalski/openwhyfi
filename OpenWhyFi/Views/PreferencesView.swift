import SwiftUI
import CoreLocation

struct PreferencesView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var locationStatus: CLAuthorizationStatus = .notDetermined
    @State private var showAdvanced = false
    let onRequestLocation: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("General") {
                    Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    Picker("Refresh interval", selection: $settings.refreshInterval) {
                        Text("3 seconds").tag(3)
                        Text("5 seconds").tag(5)
                        Text("10 seconds").tag(10)
                        Text("30 seconds").tag(30)
                    }
                }

                Section {
                    if hasLocationPermission {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Wi-Fi name access granted")
                            }
                            .font(.caption)

                            Button("Revoke in System Settings...") {
                                openLocationSettings()
                            }
                            .buttonStyle(.link)
                            .font(.caption2)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Show Wi-Fi network name")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("Requires location permission. Apple considers Wi-Fi names location-sensitive. Your location is never collected or shared.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Button("Grant Permission") {
                                onRequestLocation()
                                // Check status after a delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    updateLocationStatus()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Privacy")
                }

                Section("Visible Sections") {
                    Toggle("Wi-Fi Info", isOn: $settings.showWiFiInfo)
                    Toggle("Signal Chart", isOn: $settings.showSignalChart)
                    Toggle("Network Health", isOn: $settings.showConnectionStatus)
                    Toggle("Speed Test", isOn: $settings.showSpeedTest)
                    Toggle("Suggestions", isOn: $settings.showSuggestions)
                }

                Section {
                    DisclosureGroup("Advanced", isExpanded: $showAdvanced) {
                        advancedSettings
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.return)
            }
            .padding()
        }
        .frame(width: 320, height: showAdvanced ? 800 : 420)
        .animation(.easeInOut(duration: 0.2), value: showAdvanced)
        .onAppear {
            updateLocationStatus()
        }
    }

    @ViewBuilder
    private var advancedSettings: some View {
        Group {
            // Network Targets
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Network Targets").font(.caption).fontWeight(.medium)
                    Spacer()
                    Button("Reset") {
                        settings.pingTarget = AppSettings.defaults["pingTarget"] as! String
                        settings.dnsTestDomain = AppSettings.defaults["dnsTestDomain"] as! String
                    }
                    .font(.caption2)
                    .buttonStyle(.borderless)
                }
                TextField("Ping target", text: $settings.pingTarget)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                TextField("DNS test domain", text: $settings.dnsTestDomain)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            Divider()

            // Timeouts
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Timeouts (seconds)").font(.caption).fontWeight(.medium)
                    Spacer()
                    Button("Reset") {
                        settings.pingTimeout = AppSettings.defaults["pingTimeout"] as! Int
                        settings.dnsTimeout = AppSettings.defaults["dnsTimeout"] as! Int
                        settings.speedTestTimeout = AppSettings.defaults["speedTestTimeout"] as! Int
                    }
                    .font(.caption2)
                    .buttonStyle(.borderless)
                }
                HStack {
                    Text("Ping").font(.caption2).frame(width: 60, alignment: .leading)
                    TextField("", value: $settings.pingTimeout, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
                HStack {
                    Text("DNS").font(.caption2).frame(width: 60, alignment: .leading)
                    TextField("", value: $settings.dnsTimeout, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
                HStack {
                    Text("Speed").font(.caption2).frame(width: 60, alignment: .leading)
                    TextField("", value: $settings.speedTestTimeout, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
            }

            Divider()

            // History
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("History samples").font(.caption).fontWeight(.medium)
                    Spacer()
                    Button("Reset") {
                        settings.historyCapacity = AppSettings.defaults["historyCapacity"] as! Int
                    }
                    .font(.caption2)
                    .buttonStyle(.borderless)
                }
                TextField("", value: $settings.historyCapacity, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            Divider()

            // Router thresholds
            thresholdGroup(title: "Router Latency (ms)",
                          excellent: $settings.routerExcellent,
                          good: $settings.routerGood,
                          fair: $settings.routerFair,
                          keys: ("routerExcellent", "routerGood", "routerFair"))

            Divider()

            // Internet thresholds
            thresholdGroup(title: "Internet Latency (ms)",
                          excellent: $settings.internetExcellent,
                          good: $settings.internetGood,
                          fair: $settings.internetFair,
                          keys: ("internetExcellent", "internetGood", "internetFair"))

            Divider()

            // DNS thresholds
            thresholdGroup(title: "DNS Latency (ms)",
                          excellent: $settings.dnsExcellent,
                          good: $settings.dnsGood,
                          fair: $settings.dnsFair,
                          keys: ("dnsExcellent", "dnsGood", "dnsFair"))

            Divider()

            // Jitter thresholds
            thresholdGroup(title: "Jitter (ms)",
                          excellent: $settings.jitterExcellent,
                          good: $settings.jitterGood,
                          fair: $settings.jitterFair,
                          keys: ("jitterExcellent", "jitterGood", "jitterFair"))

            Divider()

            // Packet loss thresholds
            thresholdGroup(title: "Packet Loss (%)",
                          excellent: $settings.lossExcellent,
                          good: $settings.lossGood,
                          fair: $settings.lossFair,
                          keys: ("lossExcellent", "lossGood", "lossFair"))

            Divider()

            // Signal thresholds
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Signal Strength (dBm)").font(.caption).fontWeight(.medium)
                    Spacer()
                    Button("Reset") {
                        settings.signalExcellent = AppSettings.defaults["signalExcellent"] as! Int
                        settings.signalGood = AppSettings.defaults["signalGood"] as! Int
                        settings.signalFair = AppSettings.defaults["signalFair"] as! Int
                    }
                    .font(.caption2)
                    .buttonStyle(.borderless)
                }
                HStack(spacing: 8) {
                    VStack {
                        Text("Exc").font(.system(size: 9))
                        TextField("", value: $settings.signalExcellent, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption)
                    }
                    VStack {
                        Text("Good").font(.system(size: 9))
                        TextField("", value: $settings.signalGood, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption)
                    }
                    VStack {
                        Text("Fair").font(.system(size: 9))
                        TextField("", value: $settings.signalFair, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption)
                    }
                }
            }

            Divider()

            // Reset all
            Button("Reset All to Defaults") {
                settings.resetToDefaults()
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func thresholdGroup(title: String, excellent: Binding<Double>, good: Binding<Double>, fair: Binding<Double>, keys: (String, String, String)) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.caption).fontWeight(.medium)
                Spacer()
                Button("Reset") {
                    excellent.wrappedValue = AppSettings.defaults[keys.0] as! Double
                    good.wrappedValue = AppSettings.defaults[keys.1] as! Double
                    fair.wrappedValue = AppSettings.defaults[keys.2] as! Double
                }
                .font(.caption2)
                .buttonStyle(.borderless)
            }
            HStack(spacing: 8) {
                VStack {
                    Text("Exc").font(.system(size: 9))
                    TextField("", value: excellent, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
                VStack {
                    Text("Good").font(.system(size: 9))
                    TextField("", value: good, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
                VStack {
                    Text("Fair").font(.system(size: 9))
                    TextField("", value: fair, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
            }
        }
    }

    private var hasLocationPermission: Bool {
        locationStatus == .authorizedAlways || locationStatus == .authorized
    }

    private func updateLocationStatus() {
        locationStatus = CLLocationManager().authorizationStatus
    }

    private func openLocationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
    }
}
