import SwiftUI
import CoreLocation

struct PreferencesView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var locationStatus: CLAuthorizationStatus = .notDetermined
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
        .frame(width: 320, height: 420)
        .onAppear {
            updateLocationStatus()
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
