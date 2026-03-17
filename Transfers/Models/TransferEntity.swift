import Foundation
import SwiftData


@Model
final public class TransferEntity {
    @Attribute(.unique) public var id: String
    public var amount: Double
    public var noteDescription: String
    public var date: Date
    public var category: String
    public var thumbnailUrl: String?
    public var syncStatus: String // Stored as String for SwiftData compatibility
    public var createdAt: Date
    public var updatedAt: Date
    
    // MARK: - Computed Properties
    
    public var isPositive: Bool {
        amount >= 0
    }
    
    public var syncStatusEnum: SyncStatus {
        get { SyncStatus(rawValue: syncStatus) ?? .pending }
        set { syncStatus = newValue.rawValue }
    }
    
    // MARK: - Initializer
    
    public init(
        id: String,
        amount: Double,
        description: String,
        date: Date,
        category: String,
        thumbnailUrl: String? = nil,
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.amount = amount
        self.noteDescription = description
        self.date = date
        self.category = category
        self.thumbnailUrl = thumbnailUrl
        self.syncStatus = syncStatus.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Sync Status Enum
    
    public enum SyncStatus: String, CaseIterable {
        case synced
        case pending
        case failed
    }
}

// MARK: - Codable Conformance for Supabase

extension TransferEntity: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case noteDescription = "description"
        case date
        case category
        case thumbnailUrl = "thumbnail_url"
        case syncStatus = "sync_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom Encodable implementation
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(noteDescription, forKey: .noteDescription)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(thumbnailUrl, forKey: .thumbnailUrl)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    // Custom Decodable implementation
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let amount = try container.decode(Double.self, forKey: .amount)
        let description = try container.decode(String.self, forKey: .noteDescription)
        let date = try container.decode(Date.self, forKey: .date)
        let category = try container.decode(String.self, forKey: .category)
        let thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        
        self.init(
            id: id,
            amount: amount,
            description: description,
            date: date,
            category: category,
            thumbnailUrl: thumbnailUrl,
            syncStatus: .synced
        )
        
        // Set timestamps if available
        if let createdAt = try? container.decode(Date.self, forKey: .createdAt) {
            self.createdAt = createdAt
        }
        if let updatedAt = try? container.decode(Date.self, forKey: .updatedAt) {
            self.updatedAt = updatedAt
        }
    }
}

// MARK: - Equatable

extension TransferEntity: Equatable {
    public static func == (lhs: TransferEntity, rhs: TransferEntity) -> Bool {
        lhs.id == rhs.id &&
        lhs.amount == rhs.amount &&
        lhs.noteDescription == rhs.noteDescription &&
        lhs.date == rhs.date &&
        lhs.category == rhs.category &&
        lhs.thumbnailUrl == rhs.thumbnailUrl
    }
}

// MARK: - Helper Methods

public extension TransferEntity {
    
    /// Mark as needing sync
    func markForSync() {
        self.syncStatusEnum = .pending
        self.updatedAt = Date()
    }
    
    /// Mark as synced
    func markAsSynced() {
        self.syncStatusEnum = .synced
        self.updatedAt = Date()
    }
    
    /// Mark as failed
    func markAsFailed() {
        self.syncStatusEnum = .failed
        self.updatedAt = Date()
    }
}

// MARK: - Display Helpers

extension TransferEntity {
    /// Formatted amount string
    public var formattedAmount: String {
        let absAmount = abs(amount)
        let formatted = String(format: "%.2f", absAmount)
        return isPositive ? "+€\(formatted)" : "-€\(formatted)"
    }
    
    /// Formatted date string
    public var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
    
    /// Short date string
    public var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
