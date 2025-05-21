import SwiftUI

/// Landing page showing form submission and list of entries
struct ContentView: View {
    @State private var name = ""
    @State private var assetTag = ""
    @State private var alertMessage: String?
    @State private var showAdminLogin = false

    @StateObject private var viewModel = EntryViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Form {
                    TextField("Name", text: $name)
                    TextField("Asset Tag", text: $assetTag)
                    Button("Submit") { submit() }
                }
                .alert(isPresented: Binding(get: { alertMessage != nil }, set: { _ in alertMessage = nil })) {
                    Alert(title: Text(alertMessage ?? ""))
                }

                List(viewModel.entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.name)
                        Text(entry.assetTag).font(.caption)
                    }
                }
                Button("Login as Admin") { showAdminLogin = true }
                    .padding()
            }
            .navigationTitle("SwiftUIFormApp")
            .sheet(isPresented: $showAdminLogin) {
                AdminLoginView() {
                    viewModel.loadEntries()
                }
            }
        }
    }

    /// Validate fields and submit entry
    private func submit() {
        guard !name.isEmpty, !assetTag.isEmpty else {
            alertMessage = "Fields cannot be empty"
            return
        }

        guard !DatabaseManager.shared.entryExists(name: name, assetTag: assetTag) else {
            alertMessage = "Entry already exists"
            return
        }

        DatabaseManager.shared.insertEntry(name: name, assetTag: assetTag)
        name = ""
        assetTag = ""
        viewModel.loadEntries()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
