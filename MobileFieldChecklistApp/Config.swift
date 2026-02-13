import Foundation

enum AppConfig {
    /// Isi kalau kamu punya server (contoh: http://localhost:9000)
    /// Default: nil supaya app tetap jalan offline pakai sample lokal.
    static let baseURL: URL? = nil

    static func jobsEndpoint() -> URL? {
        guard let baseURL else { return nil }
        return baseURL.appendingPathComponent("api/jobs")
    }

    static func reportsEndpoint() -> URL? {
        guard let baseURL else { return nil }
        return baseURL.appendingPathComponent("api/reports")
    }
}
