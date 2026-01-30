import Foundation
import Combine

@MainActor
@Observable
class NetworkMonitor {
    private(set) var wifiInfo: WiFiInfo = .disconnected
    private(set) var networkStatus: NetworkStatus = .unknown
    private(set) var metrics = NetworkMetrics()
    private(set) var isRefreshing = false
    private(set) var lastUpdate: Date?

    private let wifiMonitor = WiFiMonitor()
    nonisolated(unsafe) private var refreshTask: Task<Void, Never>?
    nonisolated(unsafe) private var autoRefreshTask: Task<Void, Never>?

    var routerLatencyPoints: [LatencyPoint] {
        metrics.latencyPoints.elements
    }

    var internetLatencyPoints: [LatencyPoint] {
        metrics.latencyPoints.elements
    }

    init() {
        startAutoRefresh()
    }

    deinit {
        autoRefreshTask?.cancel()
        refreshTask?.cancel()
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        // Get Wi-Fi info
        wifiInfo = await wifiMonitor.currentInfo()

        // Get gateway
        let gateway = await GatewayFinder.shared.findDefaultGateway()

        // Ping router, internet, and DNS in parallel
        async let routerPingResult = pingRouter(gateway: gateway)
        async let internetPingResult = PingService.shared.ping(host: PingService.internetTarget)
        async let dnsResult = DNSService.shared.measureDNS()

        let routerPing = await routerPingResult
        let internetPing = await internetPingResult
        let dns = await dnsResult

        networkStatus = NetworkStatus(
            routerPing: routerPing,
            internetPing: internetPing,
            dnsResult: dns,
            gatewayIP: gateway
        )

        // Record metrics
        metrics.record(
            router: routerPing.latency,
            internet: internetPing.latency
        )

        lastUpdate = Date()
    }

    private func pingRouter(gateway: String?) async -> PingStatus {
        guard let gw = gateway else {
            return .error("No gateway")
        }
        return await PingService.shared.ping(host: gw)
    }

    private func startAutoRefresh() {
        autoRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                await self?.refresh()
            }
        }
    }

    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }
}
