import Foundation

struct SpeedTestResult: Equatable {
    let downloadMbps: Double
    let uploadMbps: Double
    let responsiveness: Int  // RPM (Round-trips Per Minute)
    let idleLatency: Double  // milliseconds
    let downloadLatency: Double
    let uploadLatency: Double
    let isRunning: Bool
    let error: String?

    static let idle = SpeedTestResult(
        downloadMbps: 0, uploadMbps: 0, responsiveness: 0,
        idleLatency: 0, downloadLatency: 0, uploadLatency: 0,
        isRunning: false, error: nil
    )

    var responsivenessQuality: String {
        // Apple's responsiveness scale: Low < 100, Medium 100-400, High > 400
        switch responsiveness {
        case 0..<100: return "Low"
        case 100..<400: return "Medium"
        default: return "High"
        }
    }

    var hasBufferbloat: Bool {
        // Bufferbloat detected if latency under load is significantly higher than idle
        guard idleLatency > 0 else { return false }
        let loadLatency = max(downloadLatency, uploadLatency)
        return loadLatency > idleLatency * 2 && loadLatency > 100
    }
}

actor SpeedTestService {
    static let shared = SpeedTestService()

    private var isRunning = false

    func runSpeedTest() async -> SpeedTestResult {
        guard !isRunning else {
            return SpeedTestResult(
                downloadMbps: 0, uploadMbps: 0, responsiveness: 0,
                idleLatency: 0, downloadLatency: 0, uploadLatency: 0,
                isRunning: true, error: "Test already running"
            )
        }

        isRunning = true
        defer { isRunning = false }

        let timeout = await MainActor.run { Double(AppSettings.shared.speedTestTimeout) }
        let result = await ShellExecutor.shared.executeWithStatus(
            "/usr/bin/networkQuality",
            arguments: ["-s", "-c"],
            timeout: timeout
        )

        guard result.exitCode == 0 else {
            let errorMessage: String
            if let error = result.error {
                if error.contains("timed out") {
                    errorMessage = "Test timed out - check connection"
                } else if error.contains("network") || error.contains("Network") {
                    errorMessage = "Network unavailable"
                } else {
                    errorMessage = error
                }
            } else {
                errorMessage = "Speed test failed (code \(result.exitCode))"
            }
            return SpeedTestResult(
                downloadMbps: 0, uploadMbps: 0, responsiveness: 0,
                idleLatency: 0, downloadLatency: 0, uploadLatency: 0,
                isRunning: false, error: errorMessage
            )
        }

        return parseResult(result.output)
    }

    private func parseResult(_ json: String) -> SpeedTestResult {
        guard let data = json.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return SpeedTestResult(
                downloadMbps: 0, uploadMbps: 0, responsiveness: 0,
                idleLatency: 0, downloadLatency: 0, uploadLatency: 0,
                isRunning: false, error: "Parse error"
            )
        }

        let dlThroughput = dict["dl_throughput"] as? Double ?? 0
        let ulThroughput = dict["ul_throughput"] as? Double ?? 0
        let baseRtt = dict["base_rtt"] as? Double ?? 0
        let dlResponsiveness = dict["dl_responsiveness"] as? Double ?? 0
        let ulResponsiveness = dict["ul_responsiveness"] as? Double ?? 0

        // Convert throughput from bytes/sec to Mbps
        let downloadMbps = dlThroughput / 1_000_000 * 8
        let uploadMbps = ulThroughput / 1_000_000 * 8

        // Use minimum of dl/ul responsiveness as overall RPM (worst case)
        let responsiveness = Int(min(dlResponsiveness, ulResponsiveness))

        // Convert RPM to latency (60000ms / RPM = avg latency)
        let dlLatency = dlResponsiveness > 0 ? 60000.0 / dlResponsiveness : 0
        let ulLatency = ulResponsiveness > 0 ? 60000.0 / ulResponsiveness : 0

        return SpeedTestResult(
            downloadMbps: downloadMbps,
            uploadMbps: uploadMbps,
            responsiveness: responsiveness,
            idleLatency: baseRtt,
            downloadLatency: dlLatency,
            uploadLatency: ulLatency,
            isRunning: false,
            error: nil
        )
    }
}
