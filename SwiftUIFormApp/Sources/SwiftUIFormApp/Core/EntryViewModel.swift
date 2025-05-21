import Foundation
import Combine

/// View model providing CRUD operations for entries
public final class EntryViewModel: ObservableObject {
    @Published public private(set) var entries: [Entry] = []

    public init() {
        reload()
    }

    public func reload() {
        entries = DatabaseManager.shared.fetchEntries()
    }

    public func add(name: String, assetTag: String) {
        let entry = Entry(id: 0, name: name, assetTag: assetTag)
        DatabaseManager.shared.insert(entry: entry)
        reload()
    }

    public func delete(_ entry: Entry) {
        DatabaseManager.shared.delete(entry: entry)
        reload()
    }

    public func update(_ entry: Entry) {
        DatabaseManager.shared.update(entry: entry)
        reload()
    }
}
