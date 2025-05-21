import SwiftUI

/// View that handles admin authentication
struct AdminLoginView: View {
    @ObservedObject var adminVM: AdminViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                Button("Login") {
                    if adminVM.login(username: username, password: password) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Admin Login")
        }
    }
}

struct AdminLoginView_Previews: PreviewProvider {
    static var previews: some View {
        AdminLoginView(adminVM: AdminViewModel())
    }
}
