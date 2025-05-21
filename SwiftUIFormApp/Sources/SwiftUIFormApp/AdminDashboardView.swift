import SwiftUI

/// Dashboard listing all entries with ability to edit or delete
struct AdminDashboardView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var entryViewModel = EntryViewModel()
    @State private var selectedEntry: Entry?

    var body: some View {
        NavigationView {
            List {
                ForEach(entryViewModel.entries) { entry in
                    Button(action: { selectedEntry = entry }) {
                        HStack {
                            Text("#\(entry.id)")
                            VStack(alignment: .leading) {
                                Text(entry.name)
                                Text(entry.assetTag).font(.caption)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { entryViewModel.entries[$0].id }.forEach(entryViewModel.delete)
                }
            }
            .sheet(item: $selectedEntry) { entry in
                EditEntryView(entry: entry) { updated in
                    entryViewModel.update(entry: updated)
                }
            }
            .navigationTitle("Admin Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}
