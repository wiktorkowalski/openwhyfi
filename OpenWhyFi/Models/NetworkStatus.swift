import Foundation

enum PingStatus: Equatable {
    case unknown
    case success(latency: Double)
    case timeout
    case error(String)

    var latency: Double? {
        if case .success(let ms) = self {
            return ms
        }
        return nil
    }

    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}

enum LatencyQuality: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    @MainActor
    static func forRouter(_ ms: Double) -> LatencyQuality {
        let s = AppSettings.shared
        if ms < s.routerExcellent { return .excellent }
        if ms < s.routerGood { return .good }
        if ms < s.routerFair { return .fair }
        return .poor
    }

    @MainActor
    static func forInternet(_ ms: Double) -> LatencyQuality {
        let s = AppSettings.shared
        if ms < s.internetExcellent { return .excellent }
        if ms < s.internetGood { return .good }
        if ms < s.internetFair { return .fair }
        return .poor
    }

    @MainActor
    static func forDNS(_ ms: Double) -> LatencyQuality {
        let s = AppSettings.shared
        if ms < s.dnsExcellent { return .excellent }
        if ms < s.dnsGood { return .good }
        if ms < s.dnsFair { return .fair }
        return .poor
    }

    @MainActor
    static func forJitter(_ ms: Double) -> LatencyQuality {
        let s = AppSettings.shared
        if ms < s.jitterExcellent { return .excellent }
        if ms < s.jitterGood { return .good }
        if ms < s.jitterFair { return .fair }
        return .poor
    }

    @MainActor
    static func forLoss(_ percent: Double) -> LatencyQuality {
        let s = AppSettings.shared
        if percent <= s.lossExcellent { return .excellent }
        if percent < s.lossGood { return .good }
        if percent < s.lossFair { return .fair }
        return .poor
    }

    var color: String {
        switch self {
        case .excellent, .good: return "green"
        case .fair: return "yellow"
        case .poor: return "red"
        }
    }
}

struct NetworkStatus: Equatable {
    let routerPing: PingStatus
    let internetPing: PingStatus
    let dnsResult: DNSResult
    let gatewayIP: String?

    static let unknown = NetworkStatus(
        routerPing: .unknown,
        internetPing: .unknown,
        dnsResult: .unknown,
        gatewayIP: nil
    )
}
