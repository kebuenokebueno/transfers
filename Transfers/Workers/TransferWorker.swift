import Foundation
import SwiftData

//  TransferWorkerProtocol.swift
//  Transfers
//

import Foundation

@MainActor
protocol TransferWorkerProtocol: AnyObject {
    func fetchTransfers() async
    func createTransfer(_ transfer: TransferEntity) async
    func updateTransfer(_ updatedTransfer: TransferEntity) async
    func deleteTransfer(id: String) async
}

@MainActor
@Observable
class TransferWorker: TransferWorkerProtocol {
    private let swiftDataService: SwiftDataService
    private let supabaseService: SupabaseService
    
    var isLoading = false
    var isSyncing = false
    var lastError: String?
    
    init(
        swiftDataService: SwiftDataService,
        supabaseService: SupabaseService
    ) {
        self.swiftDataService = swiftDataService
        self.supabaseService = supabaseService
    }
    
    // MARK: - 📥 Fetch Transfers (Offline-First)
    
    /// Fetch transfers - loads from local, then syncs from cloud
    func fetchTransfers() async {
        isLoading = true
        lastError = nil
        
        do {
            // Sync from cloud - SwiftData will update automatically
            await syncFromCloud()
            
            let count = try swiftDataService.fetchTransfers().count
            print("✅ \(count) transfers available in SwiftData")
            
        } catch {
            lastError = "Failed to load transfers: \(error.localizedDescription)"
            print("❌ Error loading transfers: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - ➕ Create Transfer
    
    /// Create transfer - saves locally immediately, syncs to cloud
    func createTransfer(_ transfer: TransferEntity) async {
        do {
            // Save to SwiftData immediately (offline-first)
            try swiftDataService.saveTransfer(transfer)
            print("✅ Transfer saved locally: \(transfer.id)")
            
            // Sync to Supabase in background
            Task {
                await syncTransferToCloud(transfer)
            }
            
        } catch {
            lastError = "Failed to create transfer: \(error.localizedDescription)"
            print("❌ Error creating transfer: \(error)")
        }
    }
    
    // MARK: - ✏️ Update Transfer
    
    /// Update transfer - fetches from DB, updates, saves, syncs
    func updateTransfer(_ updatedTransfer: TransferEntity) async {
        do {
            // Fetch existing transfer from SwiftData
            guard let existingTransfer = try? swiftDataService.fetchTransfer(id: updatedTransfer.id) else {
                print("⚠️ Transfer not found for update: \(updatedTransfer.id)")
                lastError = "Transfer not found"
                return
            }
            
            // Update properties
            existingTransfer.amount = updatedTransfer.amount
            existingTransfer.transferDescription = updatedTransfer.transferDescription
            existingTransfer.category = updatedTransfer.category
            existingTransfer.markForSync()
            
            // Save to SwiftData
            try swiftDataService.updateTransfer(existingTransfer)
            print("✅ Transfer updated locally: \(existingTransfer.id)")
            
            // Sync to Supabase in background
            Task {
                await syncTransferToCloud(existingTransfer)
            }
            
        } catch {
            lastError = "Failed to update transfer: \(error.localizedDescription)"
            print("❌ Error updating transfer: \(error)")
        }
    }
    
    // MARK: - 🗑️ Delete Transfer
    
    /// Delete transfer - removes locally immediately, syncs to cloud
    func deleteTransfer(id: String) async {
        do {
            // Delete from SwiftData
            try swiftDataService.deleteTransfer(id: id)
            print("✅ Transfer deleted locally: \(id)")
            
            // Delete from Supabase in background
            Task {
                do {
                    try await supabaseService.deleteTransfer(id: id)
                    print("✅ Transfer deleted from cloud: \(id)")
                } catch {
                    print("⚠️ Failed to delete from cloud: \(error)")
                }
            }
            
        } catch {
            lastError = "Failed to delete transfer: \(error.localizedDescription)"
            print("❌ Error deleting transfer: \(error)")
        }
    }
    
    // MARK: - 🔄 Sync Methods
    
    /// Sync from Supabase to local SwiftData
    private func syncFromCloud() async {
        guard !isSyncing else { return }
        isSyncing = true
        
        do {
            // Fetch from Supabase
            let cloudTransfers = try await supabaseService.fetchTransfers()
            print("📥 Fetched \(cloudTransfers.count) transfers from cloud")
            
            // Merge with local transfers
            for cloudTransfer in cloudTransfers {
                if let localTransfer = try? swiftDataService.fetchTransfer(id: cloudTransfer.id) {
                    // Update if cloud is newer
                    if cloudTransfer.updatedAt > localTransfer.updatedAt {
                        try swiftDataService.deleteTransfer(id: localTransfer.id)
                        try swiftDataService.saveTransfer(cloudTransfer)
                    }
                } else {
                    // New transfer from cloud
                    try swiftDataService.saveTransfer(cloudTransfer)
                }
            }
            
            let finalCount = try swiftDataService.fetchTransfers().count
            print("✅ Sync complete: \(finalCount) transfers")
            
        } catch {
            print("⚠️ Sync from cloud failed: \(error)")
        }
        
        isSyncing = false
    }
    
    /// Sync single transfer to Supabase
    private func syncTransferToCloud(_ transfer: TransferEntity) async {
        do {
            // Check if exists in cloud
            let cloudTransfers = try await supabaseService.fetchTransfers()
            let exists = cloudTransfers.contains { $0.id == transfer.id }
            
            if exists {
                // Update
                try await supabaseService.updateTransfer(transfer)
                print("✅ Transfer updated in cloud: \(transfer.id)")
            } else {
                // Create
                try await supabaseService.createTransfer(transfer)
                print("✅ Transfer created in cloud: \(transfer.id)")
            }
            
            // Mark as synced
            transfer.markAsSynced()
            try swiftDataService.updateTransfer(transfer)
            
        } catch {
            // Mark as failed
            transfer.markAsFailed()
            try? swiftDataService.updateTransfer(transfer)
            print("❌ Failed to sync to cloud: \(error)")
        }
    }
    
    /// Sync all pending transfers to cloud
    func syncPendingTransfers() async {
        do {
            let pending = try swiftDataService.fetchPendingTransfers()
            print("🔄 Syncing \(pending.count) pending transfers...")
            
            for transfer in pending {
                await syncTransferToCloud(transfer)
            }
            
            print("✅ Pending sync complete")
        } catch {
            print("❌ Failed to sync pending: \(error)")
        }
    }
    
    // MARK: - 🔍 Search & Filter
    
    func searchTransfers(query: String) async throws -> [TransferEntity] {
        return try swiftDataService.searchTransfers(query: query)
    }
    
    func filterByCategory(category: String) async throws -> [TransferEntity] {
        return try swiftDataService.fetchTransfersByCategory(category: category)
    }
}
