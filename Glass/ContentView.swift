//
//  ContentView.swift
//  Glass
//
//  Created by Fernando Magaña on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    @State private var deviceVM = DeviceViewModel()
    @State private var sessionVM = SessionViewModel()

    var body: some View {
        NavigationSplitView {
            DeviceListView(viewModel: deviceVM)
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 320)
        } detail: {
            VStack(spacing: 0) {
                ConfigurationView(deviceVM: deviceVM, sessionVM: sessionVM)

                Divider()

                ConsoleView(sessionVM: sessionVM)
                    .padding(12)
            }
        }
        .navigationTitle("Glass")
        .onAppear {
            deviceVM.startPolling()
        }
        .onDisappear {
            deviceVM.stopPolling()
            sessionVM.stop()
        }
    }
}

#Preview {
    ContentView()
}
