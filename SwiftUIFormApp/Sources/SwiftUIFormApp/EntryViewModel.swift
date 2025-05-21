import Foundation
import Combine

/// View model providing CRUD operations for entries
final class EntryViewModel: ObservableObject {
    @Published private(set) var entries: [Entry] = []

    init() {
        reload()
    }

    func reload() {
        entries = DatabaseManager.shared.fetchEntries()
    }

    func add(name: String, assetTag: String) {
        let entry = Entry(id: 0, name: name, assetTag: assetTag)
        DatabaseManager.shared.insert(entry: entry)
        reload()
    }

    func delete(_ entry: Entry) {
        DatabaseManager.shared.delete(entry: entry)
        reload()
    }

    func update(_ entry: Entry) {
        DatabaseManager.shared.update(entry: entry)
        reload()
    }
}
