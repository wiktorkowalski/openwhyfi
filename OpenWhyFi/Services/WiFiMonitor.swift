import Foundation
import CoreWLAN
import CoreLocation

actor WiFiMonitor {
    private let wifiClient = CWWiFiClient.shared()
    nonisolated let locationManager = CLLocationManager()

    var hasLocationPermission: Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedAlways || status == .authorized
    }

    func requestLocationPermission() {
        Task { @MainActor in
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func currentInfo() -> WiFiInfo {
        guard let interface = wifiClient.interface() else {
            return .disconnected
        }

        let rssi = interface.rssiValue()

        // If RSSI is 0, likely not connected
        if rssi == 0 {
            return .disconnected
        }

        let ssid: String
        if hasLocationPermission, let name = interface.ssid() {
            ssid = name
        } else {
            ssid = "Wi-Fi Network"
        }

        let noise = interface.noiseMeasurement()
        let channel = interface.wlanChannel()?.channelNumber ?? 0
        let transmitRate = interface.transmitRate()
        let bssid = hasLocationPermission ? (interface.bssid() ?? "") : ""

        return WiFiInfo(
            ssid: ssid,
            bssid: bssid,
            rssi: rssi,
            noise: noise,
            channel: channel,
            band: WiFiBand.from(channel: channel),
            signalQuality: SignalQuality.from(rssi: rssi),
            transmitRate: transmitRate
        )
    }
}
