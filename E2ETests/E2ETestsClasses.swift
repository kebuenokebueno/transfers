//
//  E2ETestsClasses.swift
//  TransfersTests
//

import Foundation
import Supabase
@testable import Transfers

@MainActor
class TestSupabaseService {
    private let client: SupabaseClient
    private let tableName: String

    init(tableName: String = "transfers_test") {
        self.tableName = tableName
        self.client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseTestURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonTestKey
        )
    }

    // MARK: - CRUD

    func fetchTransfers() async throws -> [TransferEntity] {
        let response: [TransferEntity] = try await client
            .from(tableName)
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }

    func createTransfer(_ transfer: TransferEntity) async throws {
        try await client
            .from(tableName)
            .insert(transfer)
            .execute()
    }

    func updateTransfer(_ transfer: TransferEntity) async throws {
        try await client
            .from(tableName)
            .update(transfer)
            .eq("id", value: transfer.id)
            .execute()
    }

    func deleteTransfer(id: String) async throws {
        try await client
            .from(tableName)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Test Helpers

    func cleanupAllTestData() async throws {
        try await client
            .from(tableName)
            .delete()
            .neq("id", value: "")
            .execute()
    }

    func testConnection() async -> Bool {
        do {
            _ = try await fetchTransfers()
            return true
        } catch {
            print("E2E: Supabase connection failed: \(error)")
            return false
        }
    }
}
