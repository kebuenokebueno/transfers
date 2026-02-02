//
//  SwiftDataService.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import UIKit
import SwiftData

@MainActor
@Observable
class SwiftDataService {
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    // Current user ID for filtering
    private(set) var currentUserId: String?
    
    // Statistics
    private(set) var totalTransactions: Int = 0
    private(set) var pendingSyncCount: Int = 0
    
    init() {
        setupContainer()
    }
    
    // MARK: - Setup
    
    private func setupContainer() {
        let schema = Schema([
            Transfer.self,
            CategoryEntity.self,
            TagEntity.self,
            UserSessionEntity.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            modelContext = ModelContext(modelContainer!)
            
            // Configure context for enterprise
            modelContext?.autosaveEnabled = true
            modelContext?.undoManager = UndoManager()
            
            print("✅ SwiftData: Container initialized successfully")
        } catch {
            print("❌ SwiftData: Failed to create container: \(error)")
        }
    }
    
    func setCurrentUser(userId: String, email: String, name: String) {
        self.currentUserId = userId
        
        // Create or update user session
        Task {
            await createUserSession(userId: userId, email: email, name: name)
        }
    }
    
    // MARK: - 🗑️ Clear Data on Logout (CRITICAL)
    
    func clearAllUserData() async throws {
        guard let context = modelContext else { return }
        guard let userId = currentUserId else { return }
        
        print("🗑️ Clearing all data for user: \(userId)")
        
        // Delete transactions
        let transactionDescriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate { $0.userId == userId }
        )
        let transactions = try context.fetch(transactionDescriptor)
        for transaction in transactions {
            context.delete(transaction)
        }
        
        // Delete categories
        let categoryDescriptor = FetchDescriptor<CategoryEntity>(
            predicate: #Predicate { $0.userId == userId }
        )
        let categories = try context.fetch(categoryDescriptor)
        for category in categories {
            context.delete(category)
        }
        
        // Delete tags
        let tagDescriptor = FetchDescriptor<TagEntity>(
            predicate: #Predicate { $0.userId == userId }
        )
        let tags = try context.fetch(tagDescriptor)
        for tag in tags {
            context.delete(tag)
        }
        
        // Delete user session
        let sessionDescriptor = FetchDescriptor<UserSessionEntity>(
            predicate: #Predicate { $0.userId == userId }
        )
        let sessions = try context.fetch(sessionDescriptor)
        for session in sessions {
            context.delete(session)
        }
        
        // Save changes
        try context.save()
        
        // Clear current user
        currentUserId = nil
        totalTransactions = 0
        pendingSyncCount = 0
        
        print("✅ All user data cleared successfully")
    }
    
    // MARK: - 💾 Transaction CRUD
    
    func saveTransaction(_ transaction: Transfer) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
//        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let entity = Transfer(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.transactionDescription,
            date: transaction.date,
            category: transaction.category,
            thumbnailUrl: transaction.thumbnailUrl,
            userId: "userId"
        )
        
        context.insert(entity)
        try context.save()
        
        await updateStatistics()
        
        print("💾 Transaction saved: \(transaction.id)")
    }
    
    func fetchTransactions() async throws -> [Transfer] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
//        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<Transfer>(
//            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities
    }
    
    func fetchTransaction(id: String) async throws -> Transfer? {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
//        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == id
//                && $0.userId == userId
            }
        )
        
        let entities = try context.fetch(descriptor)
        return entities.first
    }
    
    func updateTransaction(_ transaction: Transfer) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
//        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == "transaction.id"
//                && $0.userId == userId
            }
        )
        
        let entities = try context.fetch(descriptor)
        guard let entity = entities.first else { throw SwiftDataError.entityNotFound }
        
        entity.amount = transaction.amount
        entity.transactionDescription = transaction.transactionDescription
        entity.category = transaction.category
        entity.updatedAt = Date()
        entity.syncStatus = .pending
        
        try context.save()
        
        print("✏️ Transaction updated: \(transaction.id)")
    }
    
    func deleteTransaction(id: String) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
//        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == id
//                && $0.userId == userId
            }
        )
        
        let entities = try context.fetch(descriptor)
        guard let entity = entities.first else { throw SwiftDataError.entityNotFound }
        
        context.delete(entity)
        try context.save()
        
        await updateStatistics()
        
        print("🗑️ Transaction deleted: \(id)")
    }
    
    // MARK: - 📊 Statistics & Analytics
    
    func fetchStatistics() async throws -> TransactionStatistics {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
//        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<Transfer>(
//            predicate: #Predicate { $0.userId == userId }
        )
        
        let transactions = try context.fetch(descriptor)
        
        let totalIncome = transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        let balance = totalIncome - totalExpenses
        
        // This month
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        let thisMonthTransactions = transactions.filter { $0.date >= startOfMonth }
        let monthlyTotal = thisMonthTransactions.reduce(0) { $0 + $1.amount }
        
        return TransactionStatistics(
            totalTransactions: transactions.count,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            balance: balance,
            monthlyTotal: monthlyTotal,
            averageTransaction: transactions.isEmpty ? 0 : (totalIncome + totalExpenses) / Double(transactions.count)
        )
    }
    
    private func updateStatistics() async {
        guard let context = modelContext else { return }
        guard let userId = currentUserId else { return }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        if let transactions = try? context.fetch(descriptor) {
            totalTransactions = transactions.count
            pendingSyncCount = transactions.filter { $0.syncStatus == .pending }.count
        }
    }
    
    // MARK: - 🔄 Sync Management
    
    func fetchPendingSyncTransactions() async throws -> [Transfer] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.userId == userId
//                && $0.syncStatus == .pending
            }
        )
        
        let entities = try context.fetch(descriptor)
        return entities
    }
    
    func markTransactionAsSynced(id: String) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == id && $0.userId == userId
            }
        )
        
        let entities = try context.fetch(descriptor)
        guard let entity = entities.first else { throw SwiftDataError.entityNotFound }
        
        entity.syncStatus = .synced
        try context.save()
        
        await updateStatistics()
    }
    
    // MARK: - 📂 Category Management
    
    func saveCategory(id: String, name: String, icon: String, color: String) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let category = CategoryEntity(
            id: id,
            name: name,
            icon: icon,
            color: color,
            userId: userId
        )
        
        context.insert(category)
        try context.save()
    }
    
    func fetchCategories() async throws -> [CategoryEntity] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        guard let userId = currentUserId else { throw SwiftDataError.userNotLoggedIn }
        
        let descriptor = FetchDescriptor<CategoryEntity>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        return try context.fetch(descriptor)
    }
    
    // MARK: - 👤 User Session
    
    private func createUserSession(userId: String, email: String, name: String) async {
        guard let context = modelContext else { return }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        
        // Check if session exists
        let descriptor = FetchDescriptor<UserSessionEntity>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        if let existingSessions = try? context.fetch(descriptor), let session = existingSessions.first {
            // Update existing session
            session.lastLoginDate = Date()
            session.deviceId = deviceId
        } else {
            // Create new session
            let session = UserSessionEntity(
                userId: userId,
                email: email,
                name: name,
                deviceId: deviceId
            )
            context.insert(session)
        }
        
        try? context.save()
    }
    
    // MARK: - 🔍 Search & Filter
    
    func searchTransactions(query: String) async throws -> [Transfer] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate { transaction in
                transaction.transactionDescription.localizedStandardContains(query)
            }
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchTransactionsByCategory(category: String) async throws -> [Transfer] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.category == category
            }
        )
        
        let entities = try context.fetch(descriptor)
        return entities
    }
    
    func fetchTransactionsByDateRange(from: Date, to: Date) async throws -> [Transfer] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
            }
        )
        
        return try context.fetch(descriptor)
    }
}
