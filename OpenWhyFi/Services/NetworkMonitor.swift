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
    private(set) var speedTestResult: SpeedTestResult?
    private(set) var isRunningSpeedTest = false

    private let wifiMonitor = WiFiMonitor()
    nonisolated(unsafe) private var refreshTask: Task<Void, Never>?
    nonisolated(unsafe) private var autoRefreshTask: Task<Void, Never>?

    var routerLatencyPoints: [LatencyPoint] {
        metrics.latencyPoints.elements
    }

    var internetLatencyPoints: [LatencyPoint] {
        metrics.latencyPoints.elements
    }

    var suggestions: [Suggestion] {
        SuggestionEngine.analyze(
            wifiInfo: wifiInfo,
            status: networkStatus,
            metrics: metrics,
            speedTest: speedTestResult
        )
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
                let interval = UInt64(AppSettings.shared.refreshInterval) * 1_000_000_000
                try? await Task.sleep(nanoseconds: interval)
                await self?.refresh()
            }
        }
    }

    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    func runSpeedTest() async {
        guard !isRunningSpeedTest else { return }
        isRunningSpeedTest = true
        defer { isRunningSpeedTest = false }

        speedTestResult = await SpeedTestService.shared.runSpeedTest()
    }
}
