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

    // Tile visibility settings
    var showWiFiInfo: Bool {
        didSet { UserDefaults.standard.set(showWiFiInfo, forKey: "showWiFiInfo") }
    }
    var showConnectionStatus: Bool {
        didSet { UserDefaults.standard.set(showConnectionStatus, forKey: "showConnectionStatus") }
    }
    var showLatencyHistory: Bool {
        didSet { UserDefaults.standard.set(showLatencyHistory, forKey: "showLatencyHistory") }
    }
    var showStatistics: Bool {
        didSet { UserDefaults.standard.set(showStatistics, forKey: "showStatistics") }
    }
    var showSpeedTest: Bool {
        didSet { UserDefaults.standard.set(showSpeedTest, forKey: "showSpeedTest") }
    }
    var showSuggestions: Bool {
        didSet { UserDefaults.standard.set(showSuggestions, forKey: "showSuggestions") }
    }
    var showSignalChart: Bool {
        didSet { UserDefaults.standard.set(showSignalChart, forKey: "showSignalChart") }
    }

    private init() {
        self.refreshInterval = UserDefaults.standard.object(forKey: "refreshInterval") as? Int ?? 5
        self.launchAtLogin = SMAppService.mainApp.status == .enabled

        // Load tile visibility (default all to true)
        self.showWiFiInfo = UserDefaults.standard.object(forKey: "showWiFiInfo") as? Bool ?? true
        self.showConnectionStatus = UserDefaults.standard.object(forKey: "showConnectionStatus") as? Bool ?? true
        self.showLatencyHistory = UserDefaults.standard.object(forKey: "showLatencyHistory") as? Bool ?? true
        self.showStatistics = UserDefaults.standard.object(forKey: "showStatistics") as? Bool ?? true
        self.showSpeedTest = UserDefaults.standard.object(forKey: "showSpeedTest") as? Bool ?? true
        self.showSuggestions = UserDefaults.standard.object(forKey: "showSuggestions") as? Bool ?? true
        self.showSignalChart = UserDefaults.standard.object(forKey: "showSignalChart") as? Bool ?? true
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
