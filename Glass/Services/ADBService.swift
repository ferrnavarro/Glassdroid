//
//  ADBService.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import Foundation

final class ADBService: Sendable {

    /// Searches common paths for an executable by name.
    static func locateExecutable(named name: String) -> String? {
        // Common Homebrew paths (Apple Silicon + Intel) and system paths
        let searchPaths = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin"
        ]

        for dir in searchPaths {
            let fullPath = "\(dir)/\(name)"
            if FileManager.default.isExecutableFile(atPath: fullPath) {
                return fullPath
            }
        }

        // Fallback: use /usr/bin/which
        return resolveViaWhich(name)
    }

    /// Discovers connected Android devices by running `adb devices`.
    static func discoverDevices(adbPath: String) async throws -> [Device] {
        let output = try await runProcess(executablePath: adbPath, arguments: ["devices"])
        return parseDevicesOutput(output)
    }

    // MARK: - Private

    private static func resolveViaWhich(_ name: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [name]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

            if let path, !path.isEmpty, FileManager.default.isExecutableFile(atPath: path) {
                return path
            }
        } catch {
            // Silently fail
        }
        return nil
    }

    private static func runProcess(executablePath: String, arguments: [String]) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = arguments

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = Pipe()

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
                return
            }

            process.terminationHandler = { _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                continuation.resume(returning: output)
            }
        }
    }

    private static func parseDevicesOutput(_ output: String) -> [Device] {
        var devices: [Device] = []
        let lines = output.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip header and empty lines
            if trimmed.isEmpty || trimmed.hasPrefix("List of devices") || trimmed.hasPrefix("*") {
                continue
            }

            let parts = trimmed.split(separator: "\t", maxSplits: 1)
            guard parts.count == 2 else { continue }

            let serial = String(parts[0])
            let statusString = String(parts[1]).trimmingCharacters(in: .whitespaces)

            let status: DeviceStatus
            switch statusString {
            case "device":
                status = .ready
            case "unauthorized":
                status = .unauthorized
            case "offline":
                status = .offline
            default:
                status = .unknown
            }

            devices.append(Device(serial: serial, status: status))
        }

        return devices
    }
}
