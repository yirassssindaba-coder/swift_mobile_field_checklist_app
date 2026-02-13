import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""

    @Published var errorMessage: String?
    @Published var isBusy: Bool = false

    func submit(auth: AuthService) {
        errorMessage = nil
        isBusy = true
        defer { isBusy = false }

        do {
            try auth.login(username: username, password: password)
        } catch {
            errorMessage = (error as? AppError)?.message ?? error.localizedDescription
        }
    }
}
