//
//  ToolStatusBanner.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import SwiftUI

struct ToolStatusBanner: View {
    @Bindable var deviceVM: DeviceViewModel

    var body: some View {
        if !deviceVM.adbInstalled || !deviceVM.scrcpyInstalled {
            VStack(alignment: .leading, spacing: 8) {
                Label("Missing Dependencies", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)

                if !deviceVM.adbInstalled {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("**adb** not found")
                    }
                }

                if !deviceVM.scrcpyInstalled {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("**scrcpy** not found")
                    }
                }

                Text("Install via Homebrew:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("brew install scrcpy")
                    .font(.system(.caption, design: .monospaced))
                    .padding(6)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(4)

                Button("Re-check") {
                    deviceVM.recheckTools()
                }
                .controlSize(.small)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.orange.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
