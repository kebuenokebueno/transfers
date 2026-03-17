//  Created by Inigo on 2/2/26.
//

import Foundation
import Supabase


// MARK: - Supabase Service

@MainActor
@Observable
class SupabaseService {
    private let client: SupabaseClient
    
    // Status tracking
    var isConnected = false
    var lastError: String?
    
    init() {
        // Initialize Supabase client
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
        
        print("✅ Supabase initialized")
    }
    
    // MARK: - 📝 CRUD Operations
    
    /// Fetch all transfers from Supabase
    func fetchTransfers() async throws -> [TransferEntity] {
        print("📥 Fetching transfers from Supabase...")
        
        let response: [TransferEntity] = try await client
            .from("transfers")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        
        print("✅ Fetched \(response.count) transfers")
        
        // Convert to Transfer model
        return response
    }
    
    /// Create a new transfer
    func createTransfer(_ transfer: TransferEntity) async throws {
        print("💾 Creating transfer: \(transfer.id)")
        
        try await client
            .from("transfers")
            .insert(transfer)
            .execute()
        
        print("✅ Transfer created successfully")
    }
    
    /// Update an existing transfer
    func updateTransfer(_ transfer: TransferEntity) async throws {
        print("✏️ Updating transfer: \(transfer.id)")
        
        try await client
            .from("transfers")
            .update(transfer)
            .eq("id", value: transfer.id)
            .execute()
        
        print("✅ Transfer updated successfully")
    }
    
    /// Delete a transfer
    func deleteTransfer(id: String) async throws {
        print("🗑️ Deleting transfer: \(id)")
        
        try await client
            .from("transfers")
            .delete()
            .eq("id", value: id)
            .execute()
        
        print("✅ Transfer deleted successfully")
    }
    
    /// Fetch a single transfer by ID
    func fetchTransfer(id: String) async throws -> TransferEntity? {
        print("📥 Fetching transfer: \(id)")
        
        let response: [TransferEntity] = try await client
            .from("transfers")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        return response.first
    }
    
    // MARK: - 🔍 Search & Filter
    
    /// Search transfers by description
    func searchTransfers(query: String) async throws -> [TransferEntity] {
        print("🔍 Searching transfers: \(query)")
        
        let response: [TransferEntity] = try await client
            .from("transfers")
            .select()
            .ilike("description", pattern: "%\(query)%")
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    /// Filter transfers by category
    func fetchTransfersByCategory(category: String) async throws -> [TransferEntity] {
        print("📂 Fetching transfers for category: \(category)")
        
        let response: [TransferEntity] = try await client
            .from("transfers")
            .select()
            .eq("category", value: category)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    /// Filter transfers by date range
    func fetchTransfersByDateRange(from: Date, to: Date) async throws -> [TransferEntity] {
        print("📅 Fetching transfers from \(from) to \(to)")
        
        let response: [TransferEntity] = try await client
            .from("transfers")
            .select()
            .gte("date", value: from.ISO8601Format())
            .lte("date", value: to.ISO8601Format())
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    // MARK: - 🔄 Test Connection
    
    func testConnection() async -> Bool {
        do {
            _ = try await fetchTransfers()
            isConnected = true
            lastError = nil
            print("✅ Supabase connection successful")
            return true
        } catch {
            isConnected = false
            lastError = error.localizedDescription
            print("❌ Supabase connection failed: \(error)")
            return false
        }
    }
}

// MARK: - ⚠️ Error Handling

enum SupabaseError: Error, LocalizedError {
    case connectionFailed
    case notFound
    case invalidData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Failed to connect to Supabase"
        case .notFound:
            return "Transfer not found"
        case .invalidData:
            return "Invalid data format"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}
