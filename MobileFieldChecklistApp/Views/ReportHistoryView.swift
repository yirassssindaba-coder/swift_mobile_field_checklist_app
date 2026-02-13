import SwiftUI

struct ReportHistoryView: View {
    @EnvironmentObject private var appState: AppState

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

                        Button("Sync Now") {
                            Task { await appState.sync.syncAll() }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Section("Queue (Pending/Failed)") {
                    if appState.store.queue.isEmpty {
                        Text("Tidak ada laporan di queue.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.store.queue) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.report.jobTitle).font(.headline)
                                Text(item.report.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 12) {
                                    Label("Attempt: \(item.attempts)", systemImage: "arrow.triangle.2.circlepath")
                                        .font(.caption)

                                    if let next = item.nextRetryAt {
                                        Label("Retry: \(next.formatted(date: .omitted, time: .standard))", systemImage: "clock")
                                            .font(.caption)
                                    }
                                }
                                .foregroundStyle(.secondary)

                                if let err = item.lastError {
                                    Text("Error: \(err)")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Terkirim (Lokal)") {
                    if appState.store.sentReports.isEmpty {
                        Text("Belum ada laporan terkirim.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.store.sentReports.prefix(30)) { rep in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(rep.jobTitle).font(.headline)
                                Text(rep.completedAt?.formatted(date: .abbreviated, time: .shortened) ?? "-")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    Text("\(rep.attachments.count) foto")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(rep.status.rawValue.uppercased())
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.thinMaterial)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Reports")
        }
    }
}
