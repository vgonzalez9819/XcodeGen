import SwiftUI

/// View used to edit an entry
struct EditEntryView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var entry: Entry
    var onSave: (Entry) -> Void

    init(entry: Entry, onSave: @escaping (Entry) -> Void) {
        _entry = State(initialValue: entry)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $entry.name)
                TextField("Asset Tag", text: $entry.assetTag)
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(entry)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
