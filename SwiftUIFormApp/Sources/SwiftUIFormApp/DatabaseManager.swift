import Foundation
import SQLite3
import CryptoKit

/// Singleton responsible for managing the SQLite database
final class DatabaseManager {
    static let shared = DatabaseManager()

    private let dbURL: URL
    private var db: OpaquePointer?

    private init() {
        // Store database in Documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        dbURL = paths[0].appendingPathComponent("form.sqlite")
        openDatabase()
        createTables()
        insertDefaultAdminIfNeeded()
    }

    deinit {
        sqlite3_close(db)
    }

    /// Open or create the SQLite database
    private func openDatabase() {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database at \(dbURL.path)")
        }
    }

    /// Create entries and admins tables
    private func createTables() {
        let createEntries = """
            CREATE TABLE IF NOT EXISTS entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                assetTag TEXT
            );
            """

        let createAdmins = """
            CREATE TABLE IF NOT EXISTS admins (
                username TEXT PRIMARY KEY,
                password TEXT
            );
            """

        if sqlite3_exec(db, createEntries, nil, nil, nil) != SQLITE_OK {
            print("Failed to create entries table")
        }

        if sqlite3_exec(db, createAdmins, nil, nil, nil) != SQLITE_OK {
            print("Failed to create admins table")
        }
    }

    /// Insert default admin credentials if not already present
    private func insertDefaultAdminIfNeeded() {
        let query = "SELECT username FROM admins WHERE username = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, "admin", -1, nil)
            if sqlite3_step(statement) != SQLITE_ROW {
                sqlite3_finalize(statement)
                insertAdmin(username: "admin", password: "$uper@dmin")
                return
            }
        }
        sqlite3_finalize(statement)
    }

    /// Insert an admin with hashed password
    private func insertAdmin(username: String, password: String) {
        let insert = "INSERT INTO admins (username, password) VALUES (?, ?)"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            let hashed = SHA256.hash(data: Data(password.utf8)).compactMap { String(format: "%02x", $0) }.joined()
            sqlite3_bind_text(statement, 2, (hashed as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to insert admin")
            }
        }
        sqlite3_finalize(statement)
    }

    // MARK: Entry CRUD

    func insertEntry(name: String, assetTag: String) {
        let insert = "INSERT INTO entries (name, assetTag) VALUES (?, ?)"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (assetTag as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to insert entry")
            }
        }
        sqlite3_finalize(statement)
    }

    func fetchEntries() -> [Entry] {
        var results: [Entry] = []
        let query = "SELECT id, name, assetTag FROM entries ORDER BY id DESC"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let assetTag = String(cString: sqlite3_column_text(statement, 2))
                results.append(Entry(id: Int(id), name: name, assetTag: assetTag))
            }
        }
        sqlite3_finalize(statement)
        return results
    }

    func updateEntry(_ entry: Entry) {
        let update = "UPDATE entries SET name = ?, assetTag = ? WHERE id = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, update, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (entry.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (entry.assetTag as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(entry.id))
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to update entry")
            }
        }
        sqlite3_finalize(statement)
    }

    func deleteEntry(id: Int) {
        let delete = "DELETE FROM entries WHERE id = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, delete, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to delete entry")
            }
        }
        sqlite3_finalize(statement)
    }

    // MARK: Admin

    /// Validate admin credentials using SHA256
    func validateAdminCredentials(username: String, password: String) -> Bool {
        let query = "SELECT password FROM admins WHERE username = ?"
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return false }
        sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
        guard sqlite3_step(statement) == SQLITE_ROW else { return false }
        guard let cPassword = sqlite3_column_text(statement, 0) else { return false }
        let storedHash = String(cString: cPassword)
        let hash = SHA256.hash(data: Data(password.utf8)).compactMap { String(format: "%02x", $0) }.joined()
        return storedHash == hash
    }

    /// Check if an entry with the same name and assetTag exists
    func entryExists(name: String, assetTag: String) -> Bool {
        let query = "SELECT 1 FROM entries WHERE name = ? AND assetTag = ?"
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return false }
        sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (assetTag as NSString).utf8String, -1, nil)
        return sqlite3_step(statement) == SQLITE_ROW
    }
}

/// Simple model used by view models
struct Entry: Identifiable, Equatable {
    let id: Int
    var name: String
    var assetTag: String
}
