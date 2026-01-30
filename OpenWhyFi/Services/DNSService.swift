import Foundation

struct DNSResult: Equatable {
    let server: String
    let queryTime: Double // milliseconds
    let success: Bool

    static let unknown = DNSResult(server: "—", queryTime: 0, success: false)
}

actor DNSService {
    static let shared = DNSService()

    @MainActor
    static var testDomain: String { AppSettings.shared.dnsTestDomain }

    func measureDNS(server: String? = nil) async -> DNSResult {
        let domain = await MainActor.run { AppSettings.shared.dnsTestDomain }
        let timeout = await MainActor.run { Double(AppSettings.shared.dnsTimeout) }

        var args = ["+noall", "+stats", domain]

        if let server = server {
            args.insert("@\(server)", at: 0)
        }

        let result = await ShellExecutor.shared.executeWithStatus(
            "/usr/bin/dig",
            arguments: args,
            timeout: timeout
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
