//
//  TransferListE2ETests.swift
//  TransfersTests
//

import Testing
import Foundation
import SwiftData
@testable import Transfers

@Suite("TransferList - E2E Tests", .tags(.e2e))
struct TransferListE2ETests {

    // MARK: - Connection

    @MainActor
    @Test("E2E: Supabase connection works")
    func e2eConnection() async throws {
        let supabase = TestSupabaseService()
        let connected = await supabase.testConnection()
        #expect(connected == true, "Supabase must be reachable for E2E tests")
    }

    // MARK: - Create

    @MainActor
    @Test("E2E: Create transfer syncs to Supabase")
    func e2eCreateNote() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let container = try ModelContainer(
            for: TransferEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let swiftDataService = SwiftDataService(modelContainer: container)

        let transfer = TransferEntity(
            id: "e2e_create_\(UUID().uuidString)",
            amount: -42.50,
            description: "E2E Test Transfer",
            date: Date(),
            category: "Food"
        )

        try swiftDataService.saveTransfer(transfer)
        try await supabase.createTransfer(transfer)

        let cloudTransfers = try await supabase.fetchTransfers()
        #expect(cloudTransfers.contains(where: { $0.id == transfer.id }))
        #expect(cloudTransfers.first(where: { $0.id == transfer.id })?.noteDescription == "E2E Test Transfer")

        try await supabase.deleteTransfer(id: transfer.id)
    }

    // MARK: - Full Sync Cycle

    @MainActor
    @Test("E2E: Full sync cycle - local to cloud to local")
    func e2eFullSyncCycle() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let transferId = "e2e_sync_\(UUID().uuidString)"
        let originalNote = TransferEntity(
            id: transferId,
            amount: -100.00,
            description: "Created on Device A",
            date: Date(),
            category: "Shopping"
        )

        try await supabase.createTransfer(originalNote)

        let container = try ModelContainer(
            for: TransferEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let swiftDataService = SwiftDataService(modelContainer: container)

        let cloudTransfers = try await supabase.fetchTransfers()
        for transfer in cloudTransfers {
            try swiftDataService.saveTransfer(transfer)
        }

        let localTransfers = try swiftDataService.fetchTransfers()
        #expect(localTransfers.contains(where: { $0.id == transferId }))
        #expect(localTransfers.first(where: { $0.id == transferId })?.noteDescription == "Created on Device A")

        try await supabase.cleanupAllTestData()
    }

    // MARK: - Update Sync

    @MainActor
    @Test("E2E: Update syncs correctly")
    func e2eUpdateSync() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let transferId = "e2e_update_\(UUID().uuidString)"
        let transfer = TransferEntity(
            id: transferId,
            amount: -50.00,
            description: "Original",
            date: Date(),
            category: "Food"
        )
        try await supabase.createTransfer(transfer)

        transfer.noteDescription = "Updated via E2E"
        transfer.amount = -75.00
        transfer.category = "Entertainment"
        try await supabase.updateTransfer(transfer)

        let cloudTransfers = try await supabase.fetchTransfers()
        let updated = cloudTransfers.first(where: { $0.id == transferId })
        #expect(updated != nil)
        #expect(updated?.noteDescription == "Updated via E2E")
        #expect(updated?.amount == -75.00)
        #expect(updated?.category == "Entertainment")

        try await supabase.cleanupAllTestData()
    }

    // MARK: - Delete Sync

    @MainActor
    @Test("E2E: Delete syncs correctly")
    func e2eDeleteSync() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let transferId = "e2e_delete_\(UUID().uuidString)"
        let transfer = TransferEntity(
            id: transferId,
            amount: -25.00,
            description: "To be deleted",
            date: Date(),
            category: "Other"
        )
        try await supabase.createTransfer(transfer)

        var cloudTransfers = try await supabase.fetchTransfers()
        #expect(cloudTransfers.contains(where: { $0.id == transferId }))

        try await supabase.deleteTransfer(id: transferId)

        cloudTransfers = try await supabase.fetchTransfers()
        #expect(!cloudTransfers.contains(where: { $0.id == transferId }))
    }

    // MARK: - Conflict Resolution

    @MainActor
    @Test("E2E: Last write wins on conflict")
    func e2eConflictResolution() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let transferId = "e2e_conflict_\(UUID().uuidString)"
        let transfer = TransferEntity(
            id: transferId,
            amount: -100.00,
            description: "Original",
            date: Date(),
            category: "Food"
        )
        try await supabase.createTransfer(transfer)

        transfer.noteDescription = "Device A update"
        transfer.updatedAt = Date()
        try await supabase.updateTransfer(transfer)

        try await Task.sleep(nanoseconds: 100_000_000)

        transfer.noteDescription = "Device B update"
        transfer.updatedAt = Date()
        try await supabase.updateTransfer(transfer)

        let cloudTransfers = try await supabase.fetchTransfers()
        let final = cloudTransfers.first(where: { $0.id == transferId })
        #expect(final?.noteDescription == "Device B update")

        try await supabase.cleanupAllTestData()
    }

    // MARK: - Bulk Operations

    @MainActor
    @Test("E2E: Bulk create and fetch")
    func e2eBulkOperations() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let transfers = (1...10).map { i in
            TransferEntity(
                id: "e2e_bulk_\(i)_\(UUID().uuidString)",
                amount: Double(-i * 10),
                description: "Bulk transfer \(i)",
                date: Date(),
                category: "Test"
            )
        }

        for transfer in transfers {
            try await supabase.createTransfer(transfer)
        }

        let cloudTransfers = try await supabase.fetchTransfers()
        #expect(cloudTransfers.count >= 10)
        for transfer in transfers {
            #expect(cloudTransfers.contains(where: { $0.id == transfer.id }))
        }

        try await supabase.cleanupAllTestData()
    }

    // MARK: - Empty Database

    @MainActor
    @Test("E2E: Handles empty database gracefully")
    func e2eEmptyDatabase() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()
        let transfers = try await supabase.fetchTransfers()
        #expect(transfers.isEmpty)
    }

    // MARK: - Data Integrity

    @MainActor
    @Test("E2E: All fields persist correctly")
    func e2eDataIntegrity() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let transferId = "e2e_integrity_\(UUID().uuidString)"
        let testDescription = "Integrity test with special chars: aeiou"

        let original = TransferEntity(
            id: transferId,
            amount: -123.45,
            description: testDescription,
            date: Date(),
            category: "Special Category"
        )

        try await supabase.createTransfer(original)

        let cloudTransfers = try await supabase.fetchTransfers()
        let fetched = cloudTransfers.first(where: { $0.id == transferId })
        #expect(fetched != nil)
        #expect(fetched?.id == transferId)
        #expect(fetched?.amount == -123.45)
        #expect(fetched?.noteDescription == testDescription)
        #expect(fetched?.category == "Special Category")

        try await supabase.cleanupAllTestData()
    }
}
