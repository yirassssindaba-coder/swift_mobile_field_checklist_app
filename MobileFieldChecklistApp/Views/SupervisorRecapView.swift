import SwiftUI

struct SupervisorRecapView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Ringkasan (dari laporan sent lokal)") {
                    let sent = appState.store.sentReports
                    if sent.isEmpty {
                        Text("Belum ada data rekap. Kirim laporan dulu.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Total laporan")
                                Spacer()
                                Text("\(sent.count)")
                                    .foregroundStyle(.secondary)
                            }

                            let byJob = Dictionary(grouping: sent, by: { $0.jobTitle })
                            ForEach(byJob.keys.sorted(), id: \.self) { key in
                                HStack {
                                    Text(key)
                                    Spacer()
                                    Text("\(byJob[key]?.count ?? 0)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section("Catatan") {
                    Text("Tab ini mensimulasikan tampilan supervisor untuk rekap cepat. Jika kamu punya server, rekap bisa diambil dari endpoint backend.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Rekap")
        }
    }
}
