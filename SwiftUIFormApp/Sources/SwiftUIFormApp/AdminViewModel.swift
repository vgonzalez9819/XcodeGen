import Foundation
import Combine

/// View model handling admin authentication state
final class AdminViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var loginError: String?

    /// Validate credentials using DatabaseManager
    func login(username: String, password: String) {
        if DatabaseManager.shared.validateAdminCredentials(username: username, password: password) {
            isLoggedIn = true
            loginError = nil
        } else {
            loginError = "Invalid credentials"
        }
    }

    /// Logout current admin
    func logout() {
        isLoggedIn = false
    }
}
