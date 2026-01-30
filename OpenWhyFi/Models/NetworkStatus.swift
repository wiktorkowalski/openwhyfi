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
    let gatewayIP: String?

    static let unknown = NetworkStatus(
        routerPing: .unknown,
        internetPing: .unknown,
        gatewayIP: nil
    )
}
