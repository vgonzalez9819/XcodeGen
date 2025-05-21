import Foundation
import Combine

/// View model for user entries
final class EntryViewModel: ObservableObject {
    @Published private(set) var entries: [Entry] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadEntries()
    }

    /// Load entries from the database
    func loadEntries() {
        entries = DatabaseManager.shared.fetchEntries()
    }

    /// Add a new entry if it doesn't already exist
    func addEntry(name: String, assetTag: String) {
        guard !name.isEmpty, !assetTag.isEmpty else { return }
        guard !DatabaseManager.shared.entryExists(name: name, assetTag: assetTag) else { return }
        DatabaseManager.shared.insertEntry(name: name, assetTag: assetTag)
        loadEntries()
    }

    /// Update an existing entry
    func update(entry: Entry) {
        DatabaseManager.shared.updateEntry(entry)
        loadEntries()
    }

    /// Delete an entry
    func delete(id: Int) {
        DatabaseManager.shared.deleteEntry(id: id)
        loadEntries()
    }
}
