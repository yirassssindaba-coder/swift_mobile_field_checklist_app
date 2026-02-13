import Foundation

struct Job: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var siteName: String
    var address: String
    var checklist: [ChecklistItem]
}

struct ChecklistItem: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var required: Bool
}

enum ReportStatus: String, Codable {
    case pending
    case sent
    case failed
}

struct Report: Identifiable, Codable, Hashable {
    let id: String
    let jobId: String
    let jobTitle: String
    var createdAt: Date
    var completedAt: Date?
    var items: [ReportItem]
    var notes: String
    var attachments: [ReportAttachment]
    var location: ReportLocation?
    var status: ReportStatus
}

struct ReportItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    var checked: Bool
    var noteIfUnchecked: String?
}

struct ReportAttachment: Identifiable, Codable, Hashable {
    let id: String
    let fileName: String
    let mimeType: String
    let localPath: String // relative path in Documents/attachments
    let sizeBytes: Int
}

struct ReportLocation: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double?
}

struct ReportQueueItem: Identifiable, Codable, Hashable {
    let id: String
    var report: Report
    var attempts: Int
    var nextRetryAt: Date?
    var lastError: String?
}

extension Date {
    func iso8601String() -> String {
        ISO8601DateFormatter().string(from: self)
    }
}
