import Foundation
import ServiceManagement

@MainActor
@Observable
class AppSettings {
    static let shared = AppSettings()

    var launchAtLogin: Bool {
        didSet {
            updateLaunchAtLogin()
        }
    }

    var refreshInterval: Int {
        didSet {
            UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval")
        }
    }

    private init() {
        self.refreshInterval = UserDefaults.standard.object(forKey: "refreshInterval") as? Int ?? 5
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}
