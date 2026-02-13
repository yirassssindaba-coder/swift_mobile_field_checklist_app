import Foundation

struct JobService {
    func fetchJobs() async throws -> [Job] {
        if let url = AppConfig.jobsEndpoint() {
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw AppError.network("Gagal fetch jobs (HTTP bukan 2xx).")
            }
            return try JSONDecoder().decode([Job].self, from: data)
        } else {
            return try loadSampleJobs()
        }
    }

    private func loadSampleJobs() throws -> [Job] {
        guard let url = Bundle.main.url(forResource: "sample_jobs", withExtension: "json") else {
            throw AppError.internalError("sample_jobs.json tidak ditemukan.")
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Job].self, from: data)
    }
}
