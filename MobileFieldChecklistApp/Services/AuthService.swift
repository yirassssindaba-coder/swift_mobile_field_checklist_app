import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var username: String = ""

    private let keyLoggedIn = "mfc_isLoggedIn"
    private let keyUsername = "mfc_username"

    func load() {
        let defaults = UserDefaults.standard
        isLoggedIn = defaults.bool(forKey: keyLoggedIn)
        username = defaults.string(forKey: keyUsername) ?? ""
    }

    func login(username: String, password: String) throws {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !u.isEmpty else { throw AppError.validation("Username wajib diisi.") }
        guard p.count >= 4 else { throw AppError.validation("Password minimal 4 karakter.") }

        isLoggedIn = true
        self.username = u

        let defaults = UserDefaults.standard
        defaults.set(true, forKey: keyLoggedIn)
        defaults.set(u, forKey: keyUsername)
    }

    func logout() {
        isLoggedIn = false
        username = ""
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: keyLoggedIn)
        defaults.removeObject(forKey: keyUsername)
    }
}
