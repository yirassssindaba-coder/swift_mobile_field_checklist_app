import Foundation

@MainActor
final class SyncService: ObservableObject {
    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var lastSyncMessage: String = "Idle"

    private let store: LocalStore
    private let network: NetworkMonitor
    private var timer: Timer?

    init(store: LocalStore, network: NetworkMonitor) {
        self.store = store
        self.network = network
    }

    func startAutoSync() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { await self?.syncIfNeeded() }
        }
    }

    func syncIfNeeded() async {
        guard network.isOnline else {
            lastSyncMessage = "Offline — queue disimpan lokal."
            return
        }
        guard !store.queue.isEmpty else {
            lastSyncMessage = "Online — tidak ada queue."
            return
        }
        await syncAll()
    }

    func syncAll() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        var processedAny = false

        for item in store.queue {
            if let next = item.nextRetryAt, next > Date() { continue }
            processedAny = true

            let result = await upload(queueItem: item)
            switch result {
            case .success:
                store.markSent(queueItemId: item.id)
                lastSyncMessage = "Sync OK — 1 laporan terkirim."
            case .failure(let errMsg, let nextRetry, let attempts):
                var updated = item
                updated.attempts = attempts
                updated.lastError = errMsg
                updated.nextRetryAt = nextRetry
                updated.report.status = .failed
                store.updateQueueItem(updated)
                lastSyncMessage = "Sync gagal — retry terjadwal."
            }
        }

        if !processedAny {
            lastSyncMessage = "Menunggu jadwal retry (backoff)."
        }
    }

    private enum UploadResult {
        case success
        case failure(errMsg: String, nextRetry: Date, attempts: Int)
    }

    private func upload(queueItem: ReportQueueItem) async -> UploadResult {
        // Kalau tidak ada server, anggap sukses agar rekap lokal tetap berjalan.
        guard let endpoint = AppConfig.reportsEndpoint() else {
            return .success
        }

        do {
            let payload = try makePayload(report: queueItem.report)

            var req = URLRequest(url: endpoint)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = payload

            let (_, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                throw AppError.network("Response tidak valid.")
            }
            guard (200..<300).contains(http.statusCode) else {
                throw AppError.network("Upload gagal (HTTP \(http.statusCode)).")
            }
            return .success
        } catch {
            let attempts = min(queueItem.attempts + 1, 99)
            let next = computeNextRetry(attempt: attempts)
            let msg = (error as? AppError)?.message ?? error.localizedDescription
            return .failure(errMsg: msg, nextRetry: next, attempts: attempts)
        }
    }

    private func computeNextRetry(attempt: Int) -> Date {
        let base: Double = 2
        let seconds = min(pow(base, Double(attempt)) * 2, 300) // 2s,4s,8s,... cap 300s
        return Date().addingTimeInterval(seconds)
    }

    private func makePayload(report: Report) throws -> Data {
        struct UploadAttachment: Codable {
            let fileName: String
            let mimeType: String
            let base64: String
            let sizeBytes: Int
        }
        struct UploadReport: Codable {
            let id: String
            let jobId: String
            let jobTitle: String
            let createdAt: String
            let items: [ReportItem]
            let notes: String
            let location: ReportLocation?
            let attachments: [UploadAttachment]
        }

        let atts: [UploadAttachment] = try report.attachments.map { att in
            let fileURL = store.attachmentsDirURL().appendingPathComponent(att.localPath)
            let data = try Data(contentsOf: fileURL)
            return UploadAttachment(
                fileName: att.fileName,
                mimeType: att.mimeType,
                base64: data.base64EncodedString(),
                sizeBytes: data.count
            )
        }

        let upload = UploadReport(
            id: report.id,
            jobId: report.jobId,
            jobTitle: report.jobTitle,
            createdAt: report.createdAt.iso8601String(),
            items: report.items,
            notes: report.notes,
            location: report.location,
            attachments: atts
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(upload)
    }
}
