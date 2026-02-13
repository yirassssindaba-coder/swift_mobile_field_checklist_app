import Foundation

@MainActor
final class LocalStore: ObservableObject {

    @Published private(set) var cachedJobs: [Job] = []
    @Published private(set) var queue: [ReportQueueItem] = []
    @Published private(set) var sentReports: [Report] = []

    private let fm = FileManager.default

    init() { loadAll() }

    private func documentsURL() -> URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private func jobsFileURL() -> URL { documentsURL().appendingPathComponent("jobs_cache.json") }
    private func queueFileURL() -> URL { documentsURL().appendingPathComponent("report_queue.json") }
    private func sentFileURL() -> URL { documentsURL().appendingPathComponent("sent_reports.json") }

    func attachmentsDirURL() -> URL {
        let dir = documentsURL().appendingPathComponent("attachments", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func loadAll() {
        cachedJobs = (try? read([Job].self, from: jobsFileURL())) ?? []
        queue = (try? read([ReportQueueItem].self, from: queueFileURL())) ?? []
        sentReports = (try? read([Report].self, from: sentFileURL())) ?? []
    }

    func saveJobs(_ jobs: [Job]) {
        cachedJobs = jobs
        try? write(jobs, to: jobsFileURL())
    }

    func enqueue(_ report: Report) {
        var item = ReportQueueItem(
            id: UUID().uuidString,
            report: report,
            attempts: 0,
            nextRetryAt: nil,
            lastError: nil
        )
        item.report.status = .pending
        queue.insert(item, at: 0)
        persistQueue()
    }

    func markSent(queueItemId: String) {
        guard let idx = queue.firstIndex(where: { $0.id == queueItemId }) else { return }
        var rep = queue[idx].report
        rep.status = .sent
        rep.completedAt = Date()
        sentReports.insert(rep, at: 0)

        queue.remove(at: idx)
        persistQueue()
        persistSent()
    }

    func updateQueueItem(_ item: ReportQueueItem) {
        guard let idx = queue.firstIndex(where: { $0.id == item.id }) else { return }
        queue[idx] = item
        persistQueue()
    }

    func persistQueue() { try? write(queue, to: queueFileURL()) }
    func persistSent() { try? write(sentReports, to: sentFileURL()) }

    private func read<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }

    private func write<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        try data.write(to: url, options: [.atomic])
    }
}
