import SwiftUI

struct SubmitSummaryView: View {
    @EnvironmentObject private var appState: AppState
    let report: Report

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: appState.network.isOnline ? "checkmark.seal.fill" : "tray.and.arrow.down.fill")
                .font(.system(size: 46))
                .foregroundStyle(appState.network.isOnline ? .green : .orange)
                .padding(.top, 24)

            Text(appState.network.isOnline ? "Laporan Terkirim / Tersimpan" : "Laporan Tersimpan Offline")
                .font(.title3).bold()

            Text(appState.network.isOnline
                 ? "Jika server aktif, laporan akan dikirim. Jika gagal, otomatis retry."
                 : "Queue disimpan lokal dan akan sync otomatis saat online.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                HStack { Text("Job"); Spacer(); Text(report.jobTitle).foregroundStyle(.secondary) }
                HStack { Text("Waktu"); Spacer(); Text(report.createdAt.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(.secondary) }
                HStack { Text("Bukti"); Spacer(); Text("\(report.attachments.count) foto").foregroundStyle(.secondary) }
                HStack {
                    Text("Status Queue")
                    Spacer()
                    Text(appState.store.queue.contains(where: { $0.report.id == report.id }) ? "Pending" : "Sent")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Button {
                Task { await appState.sync.syncAll() }
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Coba Sync Sekarang")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Ringkasan")
        .navigationBarTitleDisplayMode(.inline)
    }
}
