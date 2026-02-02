//
//  TransactionStatistics.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation

struct TransactionStatistics {
    let totalTransactions: Int
    let totalIncome: Double
    let totalExpenses: Double
    let balance: Double
    let monthlyTotal: Double
    let averageTransaction: Double
}

// MARK: - ⚠️ Errors

enum SwiftDataError: Error, LocalizedError {
    case contextNotAvailable
    case userNotLoggedIn
    case entityNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .contextNotAvailable:
            return "Database context is not available"
        case .userNotLoggedIn:
            return "User must be logged in to access data"
        case .entityNotFound:
            return "Entity not found in database"
        case .saveFailed:
            return "Failed to save to database"
        }
    }
}
