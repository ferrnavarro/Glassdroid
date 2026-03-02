//
//  DeviceListView.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import SwiftUI

struct DeviceListView: View {
    @Bindable var viewModel: DeviceViewModel
    @State private var editingDeviceSerial: String?
    @State private var editingAlias: String = ""

    var body: some View {
        List(selection: $viewModel.selectedDevice) {
            Section {
                if viewModel.devices.isEmpty {
                    if viewModel.isScanning {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Scanning…")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("No devices found")
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                } else {
                    ForEach(viewModel.devices) { device in
                        DeviceRow(
                            device: device,
                            isEditing: editingDeviceSerial == device.serial,
                            editingAlias: editingDeviceSerial == device.serial ? $editingAlias : nil,
                            onCommit: { commitAlias(for: device) },
                            onCancel: { editingDeviceSerial = nil }
                        )
                        .tag(device)
                        .contextMenu {
                            Button("Rename…") {
                                editingAlias = device.alias ?? ""
                                editingDeviceSerial = device.serial
                            }
                            if device.alias != nil {
                                Button("Clear Alias") {
                                    viewModel.setAlias(nil, for: device.serial)
                                }
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Devices")
                    Spacer()
                    Button {
                        Task { await viewModel.refreshDevices() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isScanning)
                }
            }
        }
        .listStyle(.sidebar)
    }

    private func commitAlias(for device: Device) {
        let trimmed = editingAlias.trimmingCharacters(in: .whitespaces)
        viewModel.setAlias(trimmed.isEmpty ? nil : trimmed, for: device.serial)
        editingDeviceSerial = nil
    }
}

// MARK: - Device Row

struct DeviceRow: View {
    let device: Device
    var isEditing: Bool = false
    var editingAlias: Binding<String>?
    var onCommit: (() -> Void)?
    var onCancel: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                if isEditing, let binding = editingAlias {
                    TextField("Device name", text: binding)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body))
                        .onSubmit { onCommit?() }
                        .onExitCommand { onCancel?() }
                } else {
                    Text(device.displayName)
                        .font(.system(.body, design: device.alias != nil ? .default : .monospaced))
                        .lineLimit(1)

                    if device.alias != nil {
                        Text(device.serial)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Text(device.status.displayName)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch device.status {
        case .ready:
            return .green
        case .unauthorized:
            return .orange
        case .offline:
            return .red
        case .unknown:
            return .gray
        }
    }
}
