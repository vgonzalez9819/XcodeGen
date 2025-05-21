import Foundation
import Combine

/// View model handling admin authentication state
public final class AdminViewModel: ObservableObject {
    @Published public var loggedIn: Bool = false

    public func login(username: String, password: String) -> Bool {
        let success = DatabaseManager.shared.authenticate(username: username, password: password)
        loggedIn = success
        return success
    }

    public func logout() {
        loggedIn = false
    }
}
