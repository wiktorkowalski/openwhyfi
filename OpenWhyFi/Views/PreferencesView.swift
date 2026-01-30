import SwiftUI

struct PreferencesView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

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

                Section("Visible Sections") {
                    Toggle("Wi-Fi Info", isOn: $settings.showWiFiInfo)
                    Toggle("Connection Status", isOn: $settings.showConnectionStatus)
                    Toggle("Latency History", isOn: $settings.showLatencyHistory)
                    Toggle("Statistics", isOn: $settings.showStatistics)
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
        .frame(width: 320, height: 380)
    }
}
