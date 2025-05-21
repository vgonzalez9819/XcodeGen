import SwiftUI

/// Login view for admin access
struct AdminLoginView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = AdminViewModel()
    @State private var username = ""
    @State private var password = ""

    var onDismiss: (() -> Void)?

    var body: some View {
        NavigationView {
            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                Button("Login") {
                    viewModel.login(username: username, password: password)
                    if viewModel.isLoggedIn {
                        presentationMode.wrappedValue.dismiss()
                        onDismiss?()
                    }
                }
                if let error = viewModel.loginError {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle("Admin Login")
        }
    }
}
