import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm: ChecklistViewModel

    @State private var showEvidence = false
    @State private var goSummary = false
    @State private var lastReport: Report?

    init(job: Job) {
        _vm = StateObject(wrappedValue: ChecklistViewModel(job: job))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                VStack(alignment: .leading, spacing: 6) {
                    Text(vm.job.title).font(.title3).bold()
                    Text("\(vm.job.siteName) • \(vm.job.address)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Checklist").font(.headline)

                    ForEach(vm.items) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: Binding(
                                get: { item.checked },
                                set: { _ in vm.toggle(item.id) }
                            )) {
                                Text(item.title)
                            }

                            if !item.checked {
                                TextField("Catatan (wajib jika tidak dicentang)", text: Binding(
                                    get: { item.noteIfUnchecked ?? "" },
                                    set: { vm.setNote(item.id, note: $0) }
                                ))
                                .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Catatan Umum").font(.headline)
                    TextEditor(text: $vm.notes)
                        .frame(minHeight: 90)
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bukti (Foto)").font(.headline)
                            Text("\(vm.attachments.count) file")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Kelola") { showEvidence = true }
                            .buttonStyle(.bordered)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lokasi").font(.headline)
                            if let loc = vm.location {
                                Text(String(format: "%.5f, %.5f", loc.latitude, loc.longitude))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Belum diambil")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button("Ambil") {
                            Task { await vm.requestLocation() }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)

                if let err = vm.errorMessage {
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    submit()
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Submit Laporan")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)

                NavigationLink("", isActive: $goSummary) {
                    if let report = lastReport {
                        SubmitSummaryView(report: report)
                    }
                }
                .hidden()
            }
            .padding(.vertical, 14)
        }
        .navigationTitle("Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEvidence) {
            EvidenceUploadView(vm: vm)
                .environmentObject(appState)
        }
    }

    private func submit() {
        if !vm.validate() { return }
        let report = vm.buildReport()
        appState.store.enqueue(report)
        lastReport = report
        goSummary = true

        Task { await appState.sync.syncIfNeeded() }
    }
}
