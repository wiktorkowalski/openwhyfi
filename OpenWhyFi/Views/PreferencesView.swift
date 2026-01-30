import SwiftUI

struct PreferencesView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
            }

            Section {
                Picker("Refresh interval", selection: $settings.refreshInterval) {
                    Text("3 seconds").tag(3)
                    Text("5 seconds").tag(5)
                    Text("10 seconds").tag(10)
                    Text("30 seconds").tag(30)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 300, height: 150)
        .padding()
    }
}
