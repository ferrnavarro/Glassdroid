//
//  ScrcpyService.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import Foundation

final class ScrcpyService {

    private var process: Process?
    private var outputPipe: Pipe?
    private var errorPipe: Pipe?

    var isRunning: Bool {
        process?.isRunning ?? false
    }

    /// Launches scrcpy with the given arguments.
    /// `onOutput` is called on a background thread whenever new output arrives.
    func launch(
        scrcpyPath: String,
        arguments: [String],
        onOutput: @escaping @Sendable (String) -> Void
    ) throws {
        // Stop any existing session first
        stop()

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: scrcpyPath)
        proc.arguments = arguments

        // Set up environment so scrcpy can find adb
        var env = ProcessInfo.processInfo.environment
        let extraPaths = "/opt/homebrew/bin:/usr/local/bin"
        if let existingPath = env["PATH"] {
            env["PATH"] = "\(extraPaths):\(existingPath)"
        } else {
            env["PATH"] = extraPaths
        }
        proc.environment = env

        let outPipe = Pipe()
        let errPipe = Pipe()
        proc.standardOutput = outPipe
        proc.standardError = errPipe

        // Read stdout asynchronously
        outPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let str = String(data: data, encoding: .utf8) else { return }
            onOutput(str)
        }

        // Read stderr asynchronously
        errPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let str = String(data: data, encoding: .utf8) else { return }
            onOutput(str)
        }

        self.outputPipe = outPipe
        self.errorPipe = errPipe
        self.process = proc

        try proc.run()
    }

    /// Terminates the running scrcpy process.
    func stop() {
        guard let proc = process, proc.isRunning else {
            cleanup()
            return
        }

        proc.terminate()

        // Give it a moment to exit gracefully, then force kill if needed
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if proc.isRunning {
                proc.interrupt()
            }
            self?.cleanup()
        }
    }

    private func cleanup() {
        outputPipe?.fileHandleForReading.readabilityHandler = nil
        errorPipe?.fileHandleForReading.readabilityHandler = nil
        outputPipe = nil
        errorPipe = nil
        process = nil
    }
}
