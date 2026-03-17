import Foundation
import SwiftData

protocol SwiftDataServiceProtocol: AnyObject {
    func fetchTransfers() throws -> [TransferEntity]
    func fetchTransfer(id: String) throws -> TransferEntity?
}

@MainActor
@Observable
class SwiftDataService: SwiftDataServiceProtocol {
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    init() {
        setupContainer()
    }
    
    // For testing
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        print("✅ SwiftData: Using injected container")
    }
    
    // MARK: - Setup
    
    private func setupContainer() {
        let schema = Schema([TransferEntity.self])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            modelContext = ModelContext(modelContainer!)
            modelContext?.autosaveEnabled = true
            
            print("✅ SwiftData: Container initialized")
        } catch {
            print("❌ SwiftData: Failed to initialize: \(error)")
        }
    }
    
    // MARK: - 💾 CRUD Operations
    
    /// Save transfer to local storage
    func saveTransfer(_ transfer: TransferEntity) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        context.insert(transfer)
        try context.save()
        
        print("💾 SwiftData: Transfer saved: \(transfer.id)")
    }
    
    /// Fetch all transfers from local storage
    func fetchTransfers() throws -> [TransferEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<TransferEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch single transfer by ID
    func fetchTransfer(id: String) throws -> TransferEntity? {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<TransferEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        return try context.fetch(descriptor).first
    }
    
    /// Update transfer in local storage
    func updateTransfer(_ transfer: TransferEntity) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        transfer.updatedAt = Date()
        try context.save()
        
        print("✏️ SwiftData: Transfer updated: \(transfer.id)")
    }
    
    /// Delete transfer from local storage
    func deleteTransfer(id: String) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<TransferEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        if let transfer = try context.fetch(descriptor).first {
            context.delete(transfer)
            try context.save()
            print("🗑️ SwiftData: Transfer deleted: \(id)")
        }
    }
    
    /// Delete all transfers
    func deleteAllTransfers() throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let transfers = try fetchTransfers()
        for transfer in transfers {
            context.delete(transfer)
        }
        try context.save()
        
        print("🗑️ SwiftData: All transfers deleted")
    }
    
    // MARK: - 🔍 Search & Filter
    
    /// Search transfers by description
    func searchTransfers(query: String) throws -> [TransferEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<TransferEntity>(
            predicate: #Predicate { transfer in
                transfer.transferDescription.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch transfers by category
    func fetchTransfersByCategory(category: String) throws -> [TransferEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<TransferEntity>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch transfers that need syncing
    func fetchPendingTransfers() throws -> [TransferEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<TransferEntity>(
            predicate: #Predicate { $0.syncStatus == "pending" }
        )
        
        return try context.fetch(descriptor)
    }
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
