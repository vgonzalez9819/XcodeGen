import Foundation

/// Model representing a single form entry
public struct Entry: Identifiable {
    public var id: Int64
    public var name: String
    public var assetTag: String
}
