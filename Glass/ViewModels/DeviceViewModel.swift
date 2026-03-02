//
//  DeviceViewModel.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class DeviceViewModel {

    var devices: [Device] = []
    var selectedDevice: Device?
    var adbPath: String?
    var scrcpyPath: String?
    var isScanning: Bool = false
    var errorMessage: String?

    var adbInstalled: Bool { adbPath != nil }
    var scrcpyInstalled: Bool { scrcpyPath != nil }

    private var pollingTask: Task<Void, Never>?
    private static let aliasesKey = "deviceAliases"

    init() {
        // Locate executables
        adbPath = ADBService.locateExecutable(named: "adb")
        scrcpyPath = ADBService.locateExecutable(named: "scrcpy")
    }

    // MARK: - Alias Persistence

    /// Returns the saved aliases dictionary from UserDefaults.
    private var savedAliases: [String: String] {
        UserDefaults.standard.dictionary(forKey: Self.aliasesKey) as? [String: String] ?? [:]
    }

    /// Saves an alias for a device serial. Pass nil or empty to remove.
    func setAlias(_ alias: String?, for serial: String) {
        var aliases = savedAliases
        if let alias, !alias.isEmpty {
            aliases[serial] = alias
        } else {
            aliases.removeValue(forKey: serial)
        }
        UserDefaults.standard.set(aliases, forKey: Self.aliasesKey)

        // Update in-memory devices
        if let idx = devices.firstIndex(where: { $0.serial == serial }) {
            devices[idx].alias = alias
        }
        // Keep selectedDevice in sync
        if selectedDevice?.serial == serial {
            selectedDevice?.alias = alias
        }
    }

    /// Returns the stored alias for a serial, if any.
    func alias(for serial: String) -> String? {
        savedAliases[serial]
    }

    /// Applies saved aliases to a list of discovered devices.
    private func applyAliases(to devices: [Device]) -> [Device] {
        let aliases = savedAliases
        return devices.map { device in
            var d = device
            d.alias = aliases[device.serial]
            return d
        }
    }

    /// Begin polling for devices every 3 seconds.
    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refreshDevices()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    /// Stop polling for devices.
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    /// Manually refresh the device list.
    func refreshDevices() async {
        guard let adbPath else {
            errorMessage = "adb not found. Install via: brew install android-platform-tools"
            return
        }

        isScanning = true
        defer { isScanning = false }

        do {
            let discovered = try await ADBService.discoverDevices(adbPath: adbPath)
            let withAliases = applyAliases(to: discovered)
            devices = withAliases
            errorMessage = nil

            // Keep selection valid
            if let selected = selectedDevice, !withAliases.contains(where: { $0.serial == selected.serial }) {
                selectedDevice = nil
            }

            // Keep selected device alias in sync
            if let selected = selectedDevice,
               let updated = withAliases.first(where: { $0.serial == selected.serial }) {
                selectedDevice = updated
            }

            // Auto-select if only one device
            if selectedDevice == nil, withAliases.count == 1 {
                selectedDevice = withAliases.first
            }
        } catch {
            errorMessage = "Failed to discover devices: \(error.localizedDescription)"
        }
    }

    /// Re-check tool availability.
    func recheckTools() {
        adbPath = ADBService.locateExecutable(named: "adb")
        scrcpyPath = ADBService.locateExecutable(named: "scrcpy")
    }
}
