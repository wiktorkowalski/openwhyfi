import Foundation
import CoreWLAN
import CoreLocation

actor WiFiMonitor {
    private let wifiClient = CWWiFiClient.shared()
    private let locationManager = CLLocationManager()

    init() {
        Task { @MainActor in
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func currentInfo() -> WiFiInfo {
        guard let interface = wifiClient.interface() else {
            return .disconnected
        }

        guard let ssid = interface.ssid() else {
            return .disconnected
        }

        let rssi = interface.rssiValue()
        let noise = interface.noiseMeasurement()
        let channel = interface.wlanChannel()?.channelNumber ?? 0
        let transmitRate = interface.transmitRate()
        let bssid = interface.bssid() ?? ""

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
