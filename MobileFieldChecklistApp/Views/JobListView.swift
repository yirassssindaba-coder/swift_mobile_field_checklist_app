import SwiftUI

struct JobListView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = JobsViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: appState.network.isOnline ? "wifi" : "wifi.slash")
                            .foregroundStyle(appState.network.isOnline ? .green : .orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(appState.network.isOnline ? "Online" : "Offline")
                                .font(.subheadline).bold()
                            Text(appState.sync.lastSyncMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("Sync") {
                            Task { await appState.sync.syncAll() }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Section("Daftar Job") {
                    if vm.isLoading {
                        HStack { Spacer(); ProgressView(); Spacer() }
                    } else if !vm.jobs.isEmpty {
                        ForEach(vm.jobs) { job in
                            NavigationLink {
                                ChecklistView(job: job)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(job.title).font(.headline)
                                    Text("\(job.siteName) • \(job.address)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    } else {
                        Text(vm.errorMessage ?? "Tidak ada job. Tarik untuk refresh.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 6)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appState.auth.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .refreshable { await vm.load(store: appState.store) }
            .task { await vm.load(store: appState.store) }
        }
    }
}
