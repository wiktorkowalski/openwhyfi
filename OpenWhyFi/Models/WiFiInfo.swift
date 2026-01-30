import Foundation

enum SignalQuality: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case none = "No Signal"

    static func from(rssi: Int, excellent: Int = -50, good: Int = -60, fair: Int = -70) -> SignalQuality {
        if rssi >= excellent { return .excellent }
        if rssi >= good { return .good }
        if rssi >= fair { return .fair }
        if rssi < fair { return .poor }
        return .none
    }

    @MainActor
    static func fromSettings(rssi: Int) -> SignalQuality {
        let s = AppSettings.shared
        return from(rssi: rssi, excellent: s.signalExcellent, good: s.signalGood, fair: s.signalFair)
    }

    var color: String {
        switch self {
        case .excellent, .good: return "green"
        case .fair: return "yellow"
        case .poor, .none: return "red"
        }
    }
}

enum WiFiBand: String {
    case band2_4GHz = "2.4 GHz"
    case band5GHz = "5 GHz"
    case band6GHz = "6 GHz"
    case unknown = "Unknown"

    static func from(channel: Int) -> WiFiBand {
        switch channel {
        case 1...14: return .band2_4GHz
        case 32...177: return .band5GHz
        case 1...233 where channel > 177: return .band6GHz
        default: return .unknown
        }
    }
}

struct WiFiInfo: Equatable {
    let ssid: String
    let bssid: String
    let rssi: Int
    let noise: Int
    let channel: Int
    let band: WiFiBand
    let signalQuality: SignalQuality
    let transmitRate: Double

    var snr: Int {
        rssi - noise
    }

    static let disconnected = WiFiInfo(
        ssid: "Not Connected",
        bssid: "",
        rssi: -100,
        noise: -100,
        channel: 0,
        band: .unknown,
        signalQuality: .none,
        transmitRate: 0
    )
}
