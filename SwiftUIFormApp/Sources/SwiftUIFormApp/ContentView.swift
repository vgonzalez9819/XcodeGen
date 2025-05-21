import SwiftUI

/// Main user-facing form view
struct ContentView: View {
    @State private var name: String = ""
    @State private var assetTag: String = ""
    @State private var showLogin: Bool = false
    @StateObject private var adminVM = AdminViewModel()
    @StateObject private var entryVM = EntryViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Form {
                    TextField("Name", text: $name)
                    TextField("Asset Tag", text: $assetTag)
                    Button("Submit") {
                        guard !name.isEmpty, !assetTag.isEmpty else { return }
                        entryVM.add(name: name, assetTag: assetTag)
                        name = ""
                        assetTag = ""
                    }
                }
                .frame(height: 180)

                Text("Past Entries")
                    .font(.headline)

                List(entryVM.entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.name)
                        Text(entry.assetTag)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button("Login as Admin") { showLogin = true }
                    .padding(.bottom)
            }
            .navigationTitle("Form")
        }
        .sheet(isPresented: $showLogin) {
            AdminLoginView(adminVM: adminVM)
        }
        .sheet(isPresented: $adminVM.loggedIn) {
            AdminDashboardView(adminVM: adminVM, entryVM: entryVM)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
