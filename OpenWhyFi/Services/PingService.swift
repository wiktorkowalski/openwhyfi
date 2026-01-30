import Foundation

actor PingService {
    static let shared = PingService()
    static let internetTarget = "8.8.8.8"

    func ping(host: String, count: Int = 1, timeout: Double = 5) async -> PingStatus {
        let result = await ShellExecutor.shared.executeWithStatus(
            "/sbin/ping",
            arguments: ["-c", "\(count)", "-t", "\(Int(timeout))", host],
            timeout: timeout + 2
        )

        if result.exitCode == 0 {
            if let latency = parseLatency(from: result.output) {
                return .success(latency: latency)
            }
        }

        if result.output.contains("Request timeout") || result.output.contains("100.0% packet loss") {
            return .timeout
        }

        return .error("Ping failed")
    }

    private func parseLatency(from output: String) -> Double? {
        // Parse "round-trip min/avg/max/stddev = 1.234/2.345/3.456/0.123 ms"
        let pattern = #"min/avg/max/stddev = [\d.]+/([\d.]+)/"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
              let avgRange = Range(match.range(at: 1), in: output) else {
            return nil
        }
        return Double(output[avgRange])
    }
}
