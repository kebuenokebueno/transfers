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
    
    // MARK: - 🗑️ Clear Data on Logout (CRITICAL)
    
    func clearAllUserData() async throws {
        guard let context = modelContext else { return }
        
        print("🗑️ Clearing all data")
        
        // Delete transactions
        let transactionDescriptor = FetchDescriptor<Transfer>()
        let transactions = try context.fetch(transactionDescriptor)
        for transaction in transactions {
            context.delete(transaction)
        }
        
        // Save changes
        try context.save()
        
        // Clear current user
        totalTransactions = 0
        pendingSyncCount = 0
        
        print("✅ All user data cleared successfully")
    }
    
    // MARK: - 💾 Transaction CRUD
    
    func saveTransaction(_ transaction: Transfer) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let entity = Transfer(
            id: transaction.id,
            amount: transaction.amount,
            description: transaction.transactionDescription,
            date: transaction.date,
            category: transaction.category,
            thumbnailUrl: transaction.thumbnailUrl,
        )
        
        context.insert(entity)
        try context.save()
        
        await updateStatistics()
        
        print("💾 Transaction saved: \(transaction.id)")
    }
    
    func fetchTransactions() async throws -> [Transfer] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities
    }
    
    func fetchTransaction(id: String) async throws -> Transfer? {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        
        let entities = try context.fetch(descriptor)
        return entities.first
    }
    
    func updateTransaction(_ transaction: Transfer) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == "transaction.id"
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
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == id
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
        
        let descriptor = FetchDescriptor<Transfer>(
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
        
        let descriptor = FetchDescriptor<Transfer>()
        
        if let transactions = try? context.fetch(descriptor) {
            totalTransactions = transactions.count
            pendingSyncCount = transactions.filter { $0.syncStatus == .pending }.count
        }
    }
    
    // MARK: - 🔄 Sync Management
    
    func fetchPendingSyncTransactions() async throws -> [Transfer] {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.syncStatus == Transfer.SyncStatus.pending
            }
        )
        
        let entities = try context.fetch(descriptor)
        return entities
    }
    
    func markTransactionAsSynced(id: String) async throws {
        guard let context = modelContext else { throw SwiftDataError.contextNotAvailable }
        
        let descriptor = FetchDescriptor<Transfer>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        
        let entities = try context.fetch(descriptor)
        guard let entity = entities.first else { throw SwiftDataError.entityNotFound }
        
        entity.syncStatus = .synced
        try context.save()
        
        await updateStatistics()
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
