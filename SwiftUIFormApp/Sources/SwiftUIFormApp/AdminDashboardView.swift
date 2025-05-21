import SwiftUI

/// View shown after admin login to manage entries
struct AdminDashboardView: View {
    @ObservedObject var adminVM: AdminViewModel
    @ObservedObject var entryVM: EntryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var editEntry: Entry?

    var body: some View {
        NavigationView {
            List {
                ForEach(entryVM.entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.name)
                        Text(entry.assetTag)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture { editEntry = entry }
                }
                .onDelete { idx in
                    idx.map { entryVM.entries[$0] }.forEach(entryVM.delete)
                }
            }
            .navigationTitle("Entries")
            .navigationBarItems(leading: Button("Logout") {
                adminVM.logout()
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(item: $editEntry) { entry in
                EditEntryView(entry: entry, entryVM: entryVM)
            }
        }
    }
}

struct AdminDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AdminDashboardView(adminVM: AdminViewModel(), entryVM: EntryViewModel())
    }
}
