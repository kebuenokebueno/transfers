//
//  Transaction.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation
import SwiftData


@Model
final public class Transfer {
    @Attribute(.unique) public var id: String
    var amount: Double
    var transactionDescription: String
    var date: Date
    var category: String
    var thumbnailUrl: String?
    var userId: String // For multi-user support
    var syncStatus: SyncStatus
    var createdAt: Date
    var updatedAt: Date
    
    public var isPositive: Bool {
        amount >= 0
    }
    
    // Relationships
    @Relationship(deleteRule: .cascade) var tags: [TagEntity]?
    @Relationship(deleteRule: .nullify, inverse: \CategoryEntity.transactions) var categoryEntity: CategoryEntity?
    
    enum SyncStatus: String, Codable {
        case synced
        case pending
        case failed
    }
    
    init(
        id: String,
        amount: Double,
        description: String,
        date: Date,
        category: String,
        thumbnailUrl: String? = nil,
        userId: String,
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.amount = amount
        self.transactionDescription = description
        self.date = date
        self.category = category
        self.thumbnailUrl = thumbnailUrl
        self.userId = userId
        self.syncStatus = syncStatus
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
