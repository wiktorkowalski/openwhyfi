import Foundation

actor GatewayFinder {
    static let shared = GatewayFinder()

    func findDefaultGateway() async -> String? {
        let result = await ShellExecutor.shared.executeWithStatus(
            "/usr/sbin/netstat",
            arguments: ["-rn"]
        )

        guard result.exitCode == 0 else { return nil }

        let lines = result.output.components(separatedBy: "\n")
        for line in lines {
            let components = line.split(separator: " ", omittingEmptySubsequences: true)
            if components.count >= 2 && components[0] == "default" {
                let gateway = String(components[1])
                if gateway.contains(".") {
                    return gateway
                }
            }
        }

        return nil
    }
}
