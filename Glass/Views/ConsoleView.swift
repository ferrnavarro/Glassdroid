//
//  ConsoleView.swift
//  Glass
//
//  Created by Fernando Magaña on 3/2/26.
//

import SwiftUI

struct ConsoleView: View {
    @Bindable var sessionVM: SessionViewModel
    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .frame(width: 16)
                    Text("Console")
                        .font(.headline)
                    Spacer()

                    if !sessionVM.consoleLog.isEmpty {
                        Button("Clear") {
                            sessionVM.clearLog()
                        }
                        .font(.caption)
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()

                ScrollViewReader { proxy in
                    ScrollView {
                        Text(sessionVM.consoleLog.isEmpty ? "No output yet." : sessionVM.consoleLog)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(sessionVM.consoleLog.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .id("consoleBottom")
                    }
                    .frame(height: 160)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                    .onChange(of: sessionVM.consoleLog) {
                        withAnimation {
                            proxy.scrollTo("consoleBottom", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }
}
