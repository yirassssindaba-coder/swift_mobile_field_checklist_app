import Foundation

@MainActor
final class JobsViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service = JobService()

    func load(store: LocalStore) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched = try await service.fetchJobs()
            jobs = fetched
            store.saveJobs(fetched)
        } catch {
            jobs = store.cachedJobs
            if jobs.isEmpty {
                errorMessage = (error as? AppError)?.message ?? error.localizedDescription
            }
        }
    }
}
