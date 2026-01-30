import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var networkMonitor: NetworkMonitor!
    private var eventMonitor: Any?
    private var preferencesWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        networkMonitor = NetworkMonitor()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "wifi", accessibilityDescription: "OpenWhyFi")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverContentView(monitor: networkMonitor)
        )

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
            Task {
                await networkMonitor.refresh()
            }
        }
    }

    func showPreferences() {
        if let window = preferencesWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "OpenWhyFi Preferences"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: PreferencesView(settings: AppSettings.shared) { [weak self] in
            Task {
                await self?.networkMonitor.requestLocationPermission()
            }
        })
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindow = window
    }
}
