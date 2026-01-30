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
    var showSpeedTest: Bool {
        didSet { UserDefaults.standard.set(showSpeedTest, forKey: "showSpeedTest") }
    }
    var showSuggestions: Bool {
        didSet { UserDefaults.standard.set(showSuggestions, forKey: "showSuggestions") }
    }
    var showSignalChart: Bool {
        didSet { UserDefaults.standard.set(showSignalChart, forKey: "showSignalChart") }
    }

    // MARK: - Network Targets
    var pingTarget: String {
        didSet { UserDefaults.standard.set(pingTarget, forKey: "pingTarget") }
    }
    var dnsTestDomain: String {
        didSet { UserDefaults.standard.set(dnsTestDomain, forKey: "dnsTestDomain") }
    }

    // MARK: - Timeout Values
    var pingTimeout: Int {
        didSet { UserDefaults.standard.set(pingTimeout, forKey: "pingTimeout") }
    }
    var dnsTimeout: Int {
        didSet { UserDefaults.standard.set(dnsTimeout, forKey: "dnsTimeout") }
    }
    var speedTestTimeout: Int {
        didSet { UserDefaults.standard.set(speedTestTimeout, forKey: "speedTestTimeout") }
    }

    // MARK: - History Buffer
    var historyCapacity: Int {
        didSet { UserDefaults.standard.set(historyCapacity, forKey: "historyCapacity") }
    }

    // MARK: - Router Latency Thresholds (ms)
    var routerExcellent: Double {
        didSet { UserDefaults.standard.set(routerExcellent, forKey: "routerExcellent") }
    }
    var routerGood: Double {
        didSet { UserDefaults.standard.set(routerGood, forKey: "routerGood") }
    }
    var routerFair: Double {
        didSet { UserDefaults.standard.set(routerFair, forKey: "routerFair") }
    }

    // MARK: - Internet Latency Thresholds (ms)
    var internetExcellent: Double {
        didSet { UserDefaults.standard.set(internetExcellent, forKey: "internetExcellent") }
    }
    var internetGood: Double {
        didSet { UserDefaults.standard.set(internetGood, forKey: "internetGood") }
    }
    var internetFair: Double {
        didSet { UserDefaults.standard.set(internetFair, forKey: "internetFair") }
    }

    // MARK: - DNS Latency Thresholds (ms)
    var dnsExcellent: Double {
        didSet { UserDefaults.standard.set(dnsExcellent, forKey: "dnsExcellent") }
    }
    var dnsGood: Double {
        didSet { UserDefaults.standard.set(dnsGood, forKey: "dnsGood") }
    }
    var dnsFair: Double {
        didSet { UserDefaults.standard.set(dnsFair, forKey: "dnsFair") }
    }

    // MARK: - Jitter Thresholds (ms)
    var jitterExcellent: Double {
        didSet { UserDefaults.standard.set(jitterExcellent, forKey: "jitterExcellent") }
    }
    var jitterGood: Double {
        didSet { UserDefaults.standard.set(jitterGood, forKey: "jitterGood") }
    }
    var jitterFair: Double {
        didSet { UserDefaults.standard.set(jitterFair, forKey: "jitterFair") }
    }

    // MARK: - Packet Loss Thresholds (%)
    var lossExcellent: Double {
        didSet { UserDefaults.standard.set(lossExcellent, forKey: "lossExcellent") }
    }
    var lossGood: Double {
        didSet { UserDefaults.standard.set(lossGood, forKey: "lossGood") }
    }
    var lossFair: Double {
        didSet { UserDefaults.standard.set(lossFair, forKey: "lossFair") }
    }

    // MARK: - Signal Strength Thresholds (dBm)
    var signalExcellent: Int {
        didSet { UserDefaults.standard.set(signalExcellent, forKey: "signalExcellent") }
    }
    var signalGood: Int {
        didSet { UserDefaults.standard.set(signalGood, forKey: "signalGood") }
    }
    var signalFair: Int {
        didSet { UserDefaults.standard.set(signalFair, forKey: "signalFair") }
    }

    // MARK: - Default Values
    static let defaults: [String: Any] = [
        "pingTarget": "8.8.8.8",
        "dnsTestDomain": "apple.com",
        "pingTimeout": 5,
        "dnsTimeout": 5,
        "speedTestTimeout": 120,
        "historyCapacity": 60,
        "routerExcellent": 5.0,
        "routerGood": 20.0,
        "routerFair": 50.0,
        "internetExcellent": 30.0,
        "internetGood": 60.0,
        "internetFair": 100.0,
        "dnsExcellent": 20.0,
        "dnsGood": 50.0,
        "dnsFair": 100.0,
        "jitterExcellent": 10.0,
        "jitterGood": 30.0,
        "jitterFair": 50.0,
        "lossExcellent": 0.0,
        "lossGood": 1.0,
        "lossFair": 3.0,
        "signalExcellent": -50,
        "signalGood": -60,
        "signalFair": -70
    ]

    private init() {
        self.refreshInterval = UserDefaults.standard.object(forKey: "refreshInterval") as? Int ?? 5
        self.launchAtLogin = SMAppService.mainApp.status == .enabled

        // Load tile visibility (default all to true)
        self.showWiFiInfo = UserDefaults.standard.object(forKey: "showWiFiInfo") as? Bool ?? true
        self.showConnectionStatus = UserDefaults.standard.object(forKey: "showConnectionStatus") as? Bool ?? true
        self.showSpeedTest = UserDefaults.standard.object(forKey: "showSpeedTest") as? Bool ?? true
        self.showSuggestions = UserDefaults.standard.object(forKey: "showSuggestions") as? Bool ?? true
        self.showSignalChart = UserDefaults.standard.object(forKey: "showSignalChart") as? Bool ?? true

        // Load advanced settings
        self.pingTarget = UserDefaults.standard.string(forKey: "pingTarget") ?? Self.defaults["pingTarget"] as! String
        self.dnsTestDomain = UserDefaults.standard.string(forKey: "dnsTestDomain") ?? Self.defaults["dnsTestDomain"] as! String
        self.pingTimeout = UserDefaults.standard.object(forKey: "pingTimeout") as? Int ?? Self.defaults["pingTimeout"] as! Int
        self.dnsTimeout = UserDefaults.standard.object(forKey: "dnsTimeout") as? Int ?? Self.defaults["dnsTimeout"] as! Int
        self.speedTestTimeout = UserDefaults.standard.object(forKey: "speedTestTimeout") as? Int ?? Self.defaults["speedTestTimeout"] as! Int
        self.historyCapacity = UserDefaults.standard.object(forKey: "historyCapacity") as? Int ?? Self.defaults["historyCapacity"] as! Int

        self.routerExcellent = UserDefaults.standard.object(forKey: "routerExcellent") as? Double ?? Self.defaults["routerExcellent"] as! Double
        self.routerGood = UserDefaults.standard.object(forKey: "routerGood") as? Double ?? Self.defaults["routerGood"] as! Double
        self.routerFair = UserDefaults.standard.object(forKey: "routerFair") as? Double ?? Self.defaults["routerFair"] as! Double

        self.internetExcellent = UserDefaults.standard.object(forKey: "internetExcellent") as? Double ?? Self.defaults["internetExcellent"] as! Double
        self.internetGood = UserDefaults.standard.object(forKey: "internetGood") as? Double ?? Self.defaults["internetGood"] as! Double
        self.internetFair = UserDefaults.standard.object(forKey: "internetFair") as? Double ?? Self.defaults["internetFair"] as! Double

        self.dnsExcellent = UserDefaults.standard.object(forKey: "dnsExcellent") as? Double ?? Self.defaults["dnsExcellent"] as! Double
        self.dnsGood = UserDefaults.standard.object(forKey: "dnsGood") as? Double ?? Self.defaults["dnsGood"] as! Double
        self.dnsFair = UserDefaults.standard.object(forKey: "dnsFair") as? Double ?? Self.defaults["dnsFair"] as! Double

        self.jitterExcellent = UserDefaults.standard.object(forKey: "jitterExcellent") as? Double ?? Self.defaults["jitterExcellent"] as! Double
        self.jitterGood = UserDefaults.standard.object(forKey: "jitterGood") as? Double ?? Self.defaults["jitterGood"] as! Double
        self.jitterFair = UserDefaults.standard.object(forKey: "jitterFair") as? Double ?? Self.defaults["jitterFair"] as! Double

        self.lossExcellent = UserDefaults.standard.object(forKey: "lossExcellent") as? Double ?? Self.defaults["lossExcellent"] as! Double
        self.lossGood = UserDefaults.standard.object(forKey: "lossGood") as? Double ?? Self.defaults["lossGood"] as! Double
        self.lossFair = UserDefaults.standard.object(forKey: "lossFair") as? Double ?? Self.defaults["lossFair"] as! Double

        self.signalExcellent = UserDefaults.standard.object(forKey: "signalExcellent") as? Int ?? Self.defaults["signalExcellent"] as! Int
        self.signalGood = UserDefaults.standard.object(forKey: "signalGood") as? Int ?? Self.defaults["signalGood"] as! Int
        self.signalFair = UserDefaults.standard.object(forKey: "signalFair") as? Int ?? Self.defaults["signalFair"] as! Int
    }

    func resetToDefaults() {
        pingTarget = Self.defaults["pingTarget"] as! String
        dnsTestDomain = Self.defaults["dnsTestDomain"] as! String
        pingTimeout = Self.defaults["pingTimeout"] as! Int
        dnsTimeout = Self.defaults["dnsTimeout"] as! Int
        speedTestTimeout = Self.defaults["speedTestTimeout"] as! Int
        historyCapacity = Self.defaults["historyCapacity"] as! Int

        routerExcellent = Self.defaults["routerExcellent"] as! Double
        routerGood = Self.defaults["routerGood"] as! Double
        routerFair = Self.defaults["routerFair"] as! Double

        internetExcellent = Self.defaults["internetExcellent"] as! Double
        internetGood = Self.defaults["internetGood"] as! Double
        internetFair = Self.defaults["internetFair"] as! Double

        dnsExcellent = Self.defaults["dnsExcellent"] as! Double
        dnsGood = Self.defaults["dnsGood"] as! Double
        dnsFair = Self.defaults["dnsFair"] as! Double

        jitterExcellent = Self.defaults["jitterExcellent"] as! Double
        jitterGood = Self.defaults["jitterGood"] as! Double
        jitterFair = Self.defaults["jitterFair"] as! Double

        lossExcellent = Self.defaults["lossExcellent"] as! Double
        lossGood = Self.defaults["lossGood"] as! Double
        lossFair = Self.defaults["lossFair"] as! Double

        signalExcellent = Self.defaults["signalExcellent"] as! Int
        signalGood = Self.defaults["signalGood"] as! Int
        signalFair = Self.defaults["signalFair"] as! Int
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
