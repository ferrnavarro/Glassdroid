//
//  Device.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import Foundation

enum DeviceStatus: String, Codable, Sendable {
    case ready = "device"
    case unauthorized = "unauthorized"
    case offline = "offline"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .ready: return "Ready"
        case .unauthorized: return "Unauthorized"
        case .offline: return "Offline"
        case .unknown: return "Unknown"
        }
    }
}

struct Device: Identifiable, Hashable, Sendable {
    var id: String { serial }
    let serial: String
    let status: DeviceStatus
    var alias: String?

    /// Shows the alias if set, otherwise falls back to the serial number.
    var displayName: String {
        if let alias, !alias.isEmpty {
            return alias
        }
        return serial
    }
}
