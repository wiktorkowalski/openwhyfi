import Foundation

struct Suggestion: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
    let severity: Severity

    enum Severity: Int, Comparable {
        case info = 0
        case warning = 1
        case critical = 2

        static func < (lhs: Severity, rhs: Severity) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

struct SuggestionEngine {
    @MainActor
    static func analyze(
        wifiInfo: WiFiInfo,
        status: NetworkStatus,
        metrics: NetworkMetrics,
        speedTest: SpeedTestResult?
    ) -> [Suggestion] {
        var suggestions: [Suggestion] = []
        let s = AppSettings.shared

        // Wi-Fi signal issues
        if wifiInfo.ssid != "Not Connected" {
            if wifiInfo.signalQuality == .poor {
                suggestions.append(Suggestion(
                    icon: "wifi.exclamationmark",
                    title: "Weak Wi-Fi signal",
                    detail: "Move closer to router or reduce obstacles",
                    severity: .warning
                ))
            }

            if wifiInfo.band == .band2_4GHz {
                suggestions.append(Suggestion(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "Using 2.4 GHz band",
                    detail: "5 GHz offers faster speeds if available",
                    severity: .info
                ))
            }
        }

        // Router connectivity
        if case .error = status.routerPing {
            suggestions.append(Suggestion(
                icon: "wifi.router.fill",
                title: "Cannot reach router",
                detail: "Check Wi-Fi connection or restart router",
                severity: .critical
            ))
        } else if case .success(let ms) = status.routerPing, ms > s.routerGood {
            suggestions.append(Suggestion(
                icon: "tortoise.fill",
                title: "High router latency",
                detail: "Local network congestion or router overloaded",
                severity: .warning
            ))
        }

        // Internet connectivity
        if case .error = status.internetPing {
            if case .success = status.routerPing {
                suggestions.append(Suggestion(
                    icon: "globe",
                    title: "No internet access",
                    detail: "Router connected but ISP may be down",
                    severity: .critical
                ))
            }
        } else if case .success(let ms) = status.internetPing, ms > s.internetFair {
            suggestions.append(Suggestion(
                icon: "clock.fill",
                title: "High internet latency",
                detail: "ISP congestion or distant server",
                severity: .warning
            ))
        }

        // DNS issues
        if !status.dnsResult.success {
            suggestions.append(Suggestion(
                icon: "questionmark.folder.fill",
                title: "DNS not responding",
                detail: "Try switching to 8.8.8.8 or 1.1.1.1",
                severity: .warning
            ))
        } else if status.dnsResult.queryTime > s.dnsFair {
            suggestions.append(Suggestion(
                icon: "magnifyingglass",
                title: "Slow DNS resolution",
                detail: "Consider using a faster DNS provider",
                severity: .info
            ))
        }

        // Packet loss
        if metrics.routerLossPercent > s.lossFair {
            suggestions.append(Suggestion(
                icon: "exclamationmark.triangle.fill",
                title: "High packet loss (\(Int(metrics.routerLossPercent))%)",
                detail: "Interference or hardware issues",
                severity: .critical
            ))
        }

        // Jitter
        if let jitter = metrics.routerJitter, jitter > s.jitterGood {
            suggestions.append(Suggestion(
                icon: "waveform.path",
                title: "High jitter (\(Int(jitter))ms)",
                detail: "May cause video/voice call issues",
                severity: .warning
            ))
        }

        // Speed test results
        if let speed = speedTest {
            if speed.hasBufferbloat {
                suggestions.append(Suggestion(
                    icon: "memorychip.fill",
                    title: "Bufferbloat detected",
                    detail: "Enable SQM/QoS on router if available",
                    severity: .warning
                ))
            }

            if speed.responsiveness < 100 {
                suggestions.append(Suggestion(
                    icon: "gauge.with.dots.needle.bottom.0percent",
                    title: "Low responsiveness",
                    detail: "Network feels sluggish under load",
                    severity: .warning
                ))
            }
        }

        return suggestions.sorted { $0.severity > $1.severity }
    }
}
