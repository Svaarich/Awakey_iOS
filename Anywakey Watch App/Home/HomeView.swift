
import SwiftUI
import WatchConnectivity

struct HomeView: View {
    
    @EnvironmentObject var dataService: WatchDS
    
    @State var loading: Bool = true
    
    var body: some View {
        VStack {
            if loading && dataService.allDevices.isEmpty {
                loadingView
            } else {
                if dataService.allDevices.isEmpty {
                    noDevicesView
                } else {
                    list
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    MenuView {
                        dataService.askForDevices()
                    }
                } label: {
                    Image(systemName: "list.bullet")
                }

            }
        }
        .navigationTitle("Devices")
        .toolbar(dataService.allDevices.isEmpty ? .hidden : .visible)
        .onAppear(perform: askForData)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
                dataService.updateStatus()
            }
        }
    }
}

extension HomeView {
    
    // MARK: FUNCTIONS
    private func askForDevices() {
        if dataService.session.isReachable {
            dataService.askForDevices()
            timer.upstream.connect().cancel()
            withAnimation(.spring) {
                loading = false
            }
        }
    }
    
    // MARK: PROPERTIES
    
    // loading progress view
    private var loadingView: some View {
        VStack(alignment: .leading) {
            Text("Awaiting connection with iPhone")
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // empty list view
    private var noDevicesView: some View {
        VStack(alignment: .leading) {
            Text("Device list is empty.")
            Text("Please add device in the iOS app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // devices list
    private var list: some View {
        List {
            // pinned devices
            ForEach(dataService.allDevices.sorted(by: { $0.isPinned && !$1.isPinned } )) { device in
                ButtonRow(device: device) {
                    dataService.sendMessage(device: device)
                }
            }
        }
        .listStyle(.carousel)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
