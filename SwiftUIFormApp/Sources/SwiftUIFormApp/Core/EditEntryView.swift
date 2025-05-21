import SwiftUI

/// View for editing an existing entry
public struct EditEntryView: View {
    public var entry: Entry
    @ObservedObject public var entryVM: EntryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String
    @State private var assetTag: String

    public init(entry: Entry, entryVM: EntryViewModel) {
        self.entry = entry
        self.entryVM = entryVM
        _name = State(initialValue: entry.name)
        _assetTag = State(initialValue: entry.assetTag)
    }

    public var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Asset Tag", text: $assetTag)
            }
            .navigationTitle("Edit Entry")
            .navigationBarItems(trailing: Button("Save") {
                var updated = entry
                updated.name = name
                updated.assetTag = assetTag
                entryVM.update(updated)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
