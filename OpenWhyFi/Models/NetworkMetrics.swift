import Foundation

struct LatencyPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let routerLatency: Double?
    let internetLatency: Double?
}

struct NetworkMetrics {
    var routerHistory: CircularBuffer<Double>
    var internetHistory: CircularBuffer<Double>
    var latencyPoints: CircularBuffer<LatencyPoint>

    init(capacity: Int = 60) {
        routerHistory = CircularBuffer(capacity: capacity)
        internetHistory = CircularBuffer(capacity: capacity)
        latencyPoints = CircularBuffer(capacity: capacity)
    }

    mutating func record(router: Double?, internet: Double?) {
        let point = LatencyPoint(
            timestamp: Date(),
            routerLatency: router,
            internetLatency: internet
        )
        latencyPoints.append(point)

        if let r = router {
            routerHistory.append(r)
        }
        if let i = internet {
            internetHistory.append(i)
        }
    }

    var routerJitter: Double? {
        calculateJitter(from: routerHistory.elements)
    }

    var internetJitter: Double? {
        calculateJitter(from: internetHistory.elements)
    }

    var routerAverage: Double? {
        let elements = routerHistory.elements
        guard !elements.isEmpty else { return nil }
        return elements.reduce(0, +) / Double(elements.count)
    }

    var internetAverage: Double? {
        let elements = internetHistory.elements
        guard !elements.isEmpty else { return nil }
        return elements.reduce(0, +) / Double(elements.count)
    }

    private func calculateJitter(from values: [Double]) -> Double? {
        guard values.count >= 2 else { return nil }
        var diffs: [Double] = []
        for i in 1..<values.count {
            diffs.append(abs(values[i] - values[i-1]))
        }
        return diffs.reduce(0, +) / Double(diffs.count)
    }
}
