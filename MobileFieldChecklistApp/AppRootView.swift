import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var auth: AuthService
    @Published var network: NetworkMonitor
    @Published var store: LocalStore
    @Published var sync: SyncService

    init() {
        let auth = AuthService()
        let network = NetworkMonitor()
        let store = LocalStore()

        self.auth = auth
        self.network = network
        self.store = store
        self.sync = SyncService(store: store, network: network)

        network.start()
        sync.startAutoSync()
        auth.load()
    }
}

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.auth.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            JobListView()
                .tabItem { Label("Jobs", systemImage: "briefcase") }

            ReportHistoryView()
                .tabItem { Label("Reports", systemImage: "doc.text") }

            SupervisorRecapView()
                .tabItem { Label("Rekap", systemImage: "chart.bar") }
        }
    }
}
