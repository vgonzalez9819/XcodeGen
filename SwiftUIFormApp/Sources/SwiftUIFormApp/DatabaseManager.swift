import Foundation
import SQLite3

/// Singleton responsible for SQLite operations
final class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTables()
        insertDefaultAdmin()
    }

    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }

    private func openDatabase() {
        let fileURL: URL
        #if os(iOS) || targetEnvironment(macCatalyst)
        fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("form.sqlite")
        #else
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("form.sqlite")
        #endif

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
        }
    }

    private func createTables() {
        let createEntries = "CREATE TABLE IF NOT EXISTS entries(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, assetTag TEXT);"
        let createAdmins = "CREATE TABLE IF NOT EXISTS admins(username TEXT PRIMARY KEY, password TEXT);"
        _ = sqlite3_exec(db, createEntries, nil, nil, nil)
        _ = sqlite3_exec(db, createAdmins, nil, nil, nil)
    }

    private func insertDefaultAdmin() {
        let insert = "INSERT OR IGNORE INTO admins(username, password) VALUES('admin', '$uper@dmin');"
        _ = sqlite3_exec(db, insert, nil, nil, nil)
    }

    // MARK: - Entry Operations

    func insert(entry: Entry) {
        var stmt: OpaquePointer?
        let query = "INSERT INTO entries(name, assetTag) VALUES(?, ?);"
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, entry.name, -1, nil)
            sqlite3_bind_text(stmt, 2, entry.assetTag, -1, nil)
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("Failed to insert entry")
            }
        }
        sqlite3_finalize(stmt)
    }

    func fetchEntries() -> [Entry] {
        var stmt: OpaquePointer?
        var result: [Entry] = []
        let query = "SELECT id, name, assetTag FROM entries ORDER BY id DESC;"
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int64(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let tag = String(cString: sqlite3_column_text(stmt, 2))
                result.append(Entry(id: id, name: name, assetTag: tag))
            }
        }
        sqlite3_finalize(stmt)
        return result
    }

    func delete(entry: Entry) {
        var stmt: OpaquePointer?
        let query = "DELETE FROM entries WHERE id=?;"
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int64(stmt, 1, entry.id)
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("Failed to delete entry")
            }
        }
        sqlite3_finalize(stmt)
    }

    func update(entry: Entry) {
        var stmt: OpaquePointer?
        let query = "UPDATE entries SET name=?, assetTag=? WHERE id=?;"
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, entry.name, -1, nil)
            sqlite3_bind_text(stmt, 2, entry.assetTag, -1, nil)
            sqlite3_bind_int64(stmt, 3, entry.id)
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("Failed to update entry")
            }
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - Admin
    func authenticate(username: String, password: String) -> Bool {
        var stmt: OpaquePointer?
        let query = "SELECT COUNT(*) FROM admins WHERE username=? AND password=?;"
        var success = false
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, username, -1, nil)
            sqlite3_bind_text(stmt, 2, password, -1, nil)
            if sqlite3_step(stmt) == SQLITE_ROW {
                let count = sqlite3_column_int(stmt, 0)
                success = count > 0
            }
        }
        sqlite3_finalize(stmt)
        return success
    }
}
