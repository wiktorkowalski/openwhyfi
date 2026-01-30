import Foundation

struct DNSResult: Equatable {
    let server: String
    let queryTime: Double // milliseconds
    let success: Bool

    static let unknown = DNSResult(server: "—", queryTime: 0, success: false)
}

actor DNSService {
    static let shared = DNSService()
    static let testDomain = "apple.com"

    func measureDNS(server: String? = nil) async -> DNSResult {
        var args = ["+noall", "+stats", DNSService.testDomain]

        if let server = server {
            args.insert("@\(server)", at: 0)
        }

        let result = await ShellExecutor.shared.executeWithStatus(
            "/usr/bin/dig",
            arguments: args,
            timeout: 5
        )

        guard result.exitCode == 0 else {
            return .unknown
        }

        // Parse query time from dig output: ";; Query time: 23 msec"
        if let queryTime = parseQueryTime(from: result.output) {
            let serverUsed = server ?? "System DNS"
            return DNSResult(server: serverUsed, queryTime: queryTime, success: true)
        }

        return .unknown
    }

    private func parseQueryTime(from output: String) -> Double? {
        let pattern = #"Query time: (\d+) msec"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
              let timeRange = Range(match.range(at: 1), in: output) else {
            return nil
        }
        return Double(output[timeRange])
    }
}
