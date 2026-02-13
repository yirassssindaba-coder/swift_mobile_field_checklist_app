import Foundation
import UIKit

@MainActor
final class ChecklistViewModel: ObservableObject {
    let job: Job

    @Published var items: [ReportItem]
    @Published var notes: String = ""
    @Published var attachments: [ReportAttachment] = []
    @Published var location: ReportLocation?
    @Published var errorMessage: String?

    private let locationService = LocationService()

    init(job: Job) {
        self.job = job
        self.items = job.checklist.map { ReportItem(id: $0.id, title: $0.title, checked: false, noteIfUnchecked: nil) }
    }

    func toggle(_ id: String) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].checked.toggle()
        if items[idx].checked { items[idx].noteIfUnchecked = nil }
    }

    func setNote(_ id: String, note: String) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].noteIfUnchecked = note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func requestLocation() async {
        locationService.requestOneShotLocation()
        try? await Task.sleep(nanoseconds: 700_000_000)

        if let loc = locationService.lastLocation {
            location = ReportLocation(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                accuracy: loc.horizontalAccuracy
            )
        }
    }

    func addCompressedPhoto(_ image: UIImage, store: LocalStore) {
        errorMessage = nil
        guard let data = ImageCompressor.compressToJpegData(image) else {
            errorMessage = "Gagal kompres foto."
            return
        }

        let id = UUID().uuidString
        let fileName = "photo_\(id).jpg"
        let url = store.attachmentsDirURL().appendingPathComponent(fileName)

        do {
            try data.write(to: url, options: [.atomic])
            attachments.append(
                ReportAttachment(
                    id: id,
                    fileName: fileName,
                    mimeType: "image/jpeg",
                    localPath: fileName,
                    sizeBytes: data.count
                )
            )
        } catch {
            errorMessage = "Gagal menyimpan foto ke storage lokal."
        }
    }

    func validate() -> Bool {
        errorMessage = nil

        for item in items {
            if !item.checked {
                let note = (item.noteIfUnchecked ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if note.count < 4 {
                    errorMessage = "Checklist belum lengkap. Jika item tidak dicentang, isi catatan minimal 4 karakter."
                    return false
                }
            }
        }
        return true
    }

    func buildReport() -> Report {
        Report(
            id: UUID().uuidString,
            jobId: job.id,
            jobTitle: job.title,
            createdAt: Date(),
            completedAt: nil,
            items: items,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            attachments: attachments,
            location: location,
            status: .pending
        )
    }
}
