//
//  SessionViewModel.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class SessionViewModel {

    var configuration = ScrcpyConfiguration()
    var consoleLog: String = ""
    var isStreaming: Bool = false
    var errorMessage: String?

    private let scrcpyService = ScrcpyService()

    /// Start mirroring the selected device.
    func start(device: Device, scrcpyPath: String) {
        guard !isStreaming else { return }

        consoleLog = ""
        errorMessage = nil

        let args = configuration.toArguments(serial: device.serial)
        let commandPreview = "scrcpy \(args.joined(separator: " "))"
        consoleLog += "$ \(commandPreview)\n"

        do {
            try scrcpyService.launch(
                scrcpyPath: scrcpyPath,
                arguments: args,
                onOutput: { [weak self] text in
                    Task { @MainActor in
                        self?.consoleLog += text
                    }
                }
            )
            isStreaming = true

            // Monitor process state
            Task {
                while scrcpyService.isRunning {
                    try? await Task.sleep(for: .seconds(0.5))
                }
                isStreaming = false
                consoleLog += "\n[scrcpy process ended]\n"
            }

        } catch {
            errorMessage = "Failed to launch scrcpy: \(error.localizedDescription)"
            consoleLog += "[ERROR] \(error.localizedDescription)\n"
        }
    }

    /// Stop the current mirroring session.
    func stop() {
        scrcpyService.stop()
        isStreaming = false
        consoleLog += "\n[Stopped by user]\n"
    }

    /// Clear the console log.
    func clearLog() {
        consoleLog = ""
    }
}
