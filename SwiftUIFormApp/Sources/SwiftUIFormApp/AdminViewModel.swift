import Foundation
import Combine

/// View model handling admin authentication state
final class AdminViewModel: ObservableObject {
    @Published var loggedIn: Bool = false

    func login(username: String, password: String) -> Bool {
        let success = DatabaseManager.shared.authenticate(username: username, password: password)
        loggedIn = success
        return success
    }

    func logout() {
        loggedIn = false
    }
}
