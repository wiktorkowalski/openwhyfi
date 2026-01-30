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

    static func forRouter(_ ms: Double) -> LatencyQuality {
        switch ms {
        case 0..<5: return .excellent
        case 5..<20: return .good
        case 20..<50: return .fair
        default: return .poor
        }
    }

    static func forInternet(_ ms: Double) -> LatencyQuality {
        switch ms {
        case 0..<30: return .excellent
        case 30..<60: return .good
        case 60..<100: return .fair
        default: return .poor
        }
    }

    static func forDNS(_ ms: Double) -> LatencyQuality {
        switch ms {
        case 0..<20: return .excellent
        case 20..<50: return .good
        case 50..<100: return .fair
        default: return .poor
        }
    }

    static func forJitter(_ ms: Double) -> LatencyQuality {
        switch ms {
        case 0..<10: return .excellent
        case 10..<30: return .good
        case 30..<50: return .fair
        default: return .poor
        }
    }

    static func forLoss(_ percent: Double) -> LatencyQuality {
        switch percent {
        case 0: return .excellent
        case 0..<1: return .good
        case 1..<3: return .fair
        default: return .poor
        }
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
