//
//  Transaction.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import Foundation


public struct Transfer: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public var amount: Double
    public var description: String
    public let date: Date
    public var category: String
    public let thumbnailUrl: String?  // URL de la imagen de la API
    public var isEditing: Bool = false
    public var isPositive: Bool {
        amount >= 0
    }
    
    public init(id: String, amount: Double, description: String, date: Date, category: String, thumbnailUrl: String?, isEditing: Bool = false) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.category = category
        self.thumbnailUrl = thumbnailUrl
        self.isEditing = isEditing
    }
    
    // Explicit Hashable implementation
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(amount)
        hasher.combine(description)
        hasher.combine(date)
        hasher.combine(category)
        hasher.combine(thumbnailUrl)
        // Intentionally exclude isEditing from hash
    }
    
    // Explicit Equatable implementation
    public static func == (lhs: Transfer, rhs: Transfer) -> Bool {
        lhs.id == rhs.id &&
        lhs.amount == rhs.amount &&
        lhs.description == rhs.description &&
        lhs.date == rhs.date &&
        lhs.category == rhs.category &&
        lhs.thumbnailUrl == rhs.thumbnailUrl
        // Intentionally exclude isEditing from equality
    }
}
