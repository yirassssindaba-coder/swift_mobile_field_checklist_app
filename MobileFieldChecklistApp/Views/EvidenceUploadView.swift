import SwiftUI
import PhotosUI

struct EvidenceUploadView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var vm: ChecklistViewModel
    @StateObject private var photoModel = PhotoPickerModel()

    @State private var showCamera = false
    @State private var info: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Ambil Foto", systemImage: "camera")
                        }
                        .buttonStyle(.bordered)

                        PhotosPicker(selection: $photoModel.selectedItem, matching: .images) {
                            Label("Pilih Galeri", systemImage: "photo.on.rectangle")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 4)

                    if let info {
                        Text(info).font(.footnote).foregroundStyle(.secondary)
                    }
                }

                Section("Daftar Bukti") {
                    if vm.attachments.isEmpty {
                        Text("Belum ada foto. Tambahkan minimal 1 (disarankan).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.attachments) { att in
                            HStack {
                                Image(systemName: "photo")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(att.fileName).font(.subheadline).bold()
                                    Text("\(att.sizeBytes / 1024) KB • \(att.mimeType)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    delete(att)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Upload Bukti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Selesai") { dismiss() }
                }
            }
            .onChange(of: photoModel.selectedItem) { _ in
                Task {
                    guard let img = await photoModel.loadImage() else { return }
                    vm.addCompressedPhoto(img, store: appState.store)
                    info = "Foto ditambahkan + dikompres aman."
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker { img in
                    vm.addCompressedPhoto(img, store: appState.store)
                    info = "Foto kamera ditambahkan + dikompres aman."
                }
            }
        }
    }

    private func delete(_ att: ReportAttachment) {
        if let idx = vm.attachments.firstIndex(where: { $0.id == att.id }) {
            vm.attachments.remove(at: idx)
        }
        let url = appState.store.attachmentsDirURL().appendingPathComponent(att.localPath)
        try? FileManager.default.removeItem(at: url)
    }
}
