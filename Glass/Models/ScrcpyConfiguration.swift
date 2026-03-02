//
//  ScrcpyConfiguration.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import Foundation

enum ResolutionOption: String, CaseIterable, Identifiable, Sendable {
    case original = "Original"
    case p1080 = "1080p"
    case p720 = "720p"

    var id: String { rawValue }

    var maxSize: Int? {
        switch self {
        case .original: return nil
        case .p1080: return 1080
        case .p720: return 720
        }
    }
}

enum FramerateOption: Int, CaseIterable, Identifiable, Sendable {
    case unlimited = 0
    case sixty = 60
    case thirty = 30

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .unlimited: return "Unlimited"
        case .sixty: return "60 FPS"
        case .thirty: return "30 FPS"
        }
    }
}

struct ScrcpyConfiguration: Sendable {
    var resolution: ResolutionOption = .original
    var bitrateMbps: Double = 8.0
    var framerate: FramerateOption = .unlimited
    var alwaysOnTop: Bool = false
    var stayAwake: Bool = false
    var turnScreenOff: Bool = false
    var audioEnabled: Bool = true
    var windowWidth: Int = 440
    var windowHeight: Int = 950

    func toArguments(serial: String) -> [String] {
        var args: [String] = ["-s", serial]

        if let maxSize = resolution.maxSize {
            args.append(contentsOf: ["--max-size", "\(maxSize)"])
        }

        let bitrateValue = Int(bitrateMbps * 1_000_000)
        args.append(contentsOf: ["--video-bit-rate", "\(bitrateValue)"])

        if framerate != .unlimited {
            args.append(contentsOf: ["--max-fps", "\(framerate.rawValue)"])
        }

        if alwaysOnTop {
            args.append("--always-on-top")
        }

        if stayAwake {
            args.append("--stay-awake")
        }

        if turnScreenOff {
            args.append("--turn-screen-off")
        }

        if !audioEnabled {
            args.append("--no-audio")
        }

        args.append(contentsOf: ["--window-width", "\(windowWidth)"])
        args.append(contentsOf: ["--window-height", "\(windowHeight)"])

        return args
    }
}
