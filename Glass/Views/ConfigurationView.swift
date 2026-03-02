//
//  ConfigurationView.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import SwiftUI

struct ConfigurationView: View {
    @Bindable var deviceVM: DeviceViewModel
    @Bindable var sessionVM: SessionViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Tool status banner
                ToolStatusBanner(deviceVM: deviceVM)

                // Start / Stop button
                startStopSection

                // Configuration form
                configurationForm
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Start/Stop Section

    @ViewBuilder
    private var startStopSection: some View {
        VStack(spacing: 12) {
            if let device = deviceVM.selectedDevice {
                HStack(spacing: 8) {
                    Circle()
                        .fill(device.status == .ready ? .green : .orange)
                        .frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(device.displayName)
                            .font(.headline)
                        if device.alias != nil {
                            Text(device.serial)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if sessionVM.isStreaming {
                    Button(action: { sessionVM.stop() }) {
                        Label("Stop Mirroring", systemImage: "stop.fill")
                            .frame(maxWidth: 280)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Button(action: startMirroring) {
                        Label("Start Mirroring", systemImage: "play.fill")
                            .frame(maxWidth: 280)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(!canStart)
                }
            } else {
                Text("Select a device from the sidebar")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }

            if let error = sessionVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Configuration Form

    @ViewBuilder
    private var configurationForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuration")
                .font(.title2.bold())

            GroupBox("Video") {
                VStack(alignment: .leading, spacing: 12) {
                    // Resolution
                    HStack {
                        Text("Resolution")
                            .frame(width: 120, alignment: .leading)
                        Picker("", selection: $sessionVM.configuration.resolution) {
                            ForEach(ResolutionOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                    }

                    // Bitrate
                    HStack {
                        Text("Bitrate")
                            .frame(width: 120, alignment: .leading)
                        Slider(value: $sessionVM.configuration.bitrateMbps, in: 1...50, step: 1)
                        Text("\(Int(sessionVM.configuration.bitrateMbps)) Mbps")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }

                    // Framerate
                    HStack {
                        Text("Framerate")
                            .frame(width: 120, alignment: .leading)
                        Picker("", selection: $sessionVM.configuration.framerate) {
                            ForEach(FramerateOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                    }

                    Divider()

                    // Window Width
                    HStack {
                        Text("Window Width")
                            .frame(width: 120, alignment: .leading)
                        Slider(
                            value: Binding(
                                get: { Double(sessionVM.configuration.windowWidth) },
                                set: { sessionVM.configuration.windowWidth = Int($0) }
                            ),
                            in: 320...1920,
                            step: 10
                        )
                        Text("\(sessionVM.configuration.windowWidth)px")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }

                    // Window Height
                    HStack {
                        Text("Window Height")
                            .frame(width: 120, alignment: .leading)
                        Slider(
                            value: Binding(
                                get: { Double(sessionVM.configuration.windowHeight) },
                                set: { sessionVM.configuration.windowHeight = Int($0) }
                            ),
                            in: 480...2560,
                            step: 10
                        )
                        Text("\(sessionVM.configuration.windowHeight)px")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }
                }
                .padding(.vertical, 4)
            }

            GroupBox("Options") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Always on Top", isOn: $sessionVM.configuration.alwaysOnTop)
                    Toggle("Stay Awake", isOn: $sessionVM.configuration.stayAwake)
                    Toggle("Turn Screen Off", isOn: $sessionVM.configuration.turnScreenOff)
                    Toggle("Audio Forwarding", isOn: $sessionVM.configuration.audioEnabled)
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private var canStart: Bool {
        guard let device = deviceVM.selectedDevice else { return false }
        return device.status == .ready && deviceVM.scrcpyInstalled && !sessionVM.isStreaming
    }

    private func startMirroring() {
        guard let device = deviceVM.selectedDevice,
              let scrcpyPath = deviceVM.scrcpyPath else { return }
        sessionVM.start(device: device, scrcpyPath: scrcpyPath)
    }
}
