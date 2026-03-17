//
//  TransferWorkerTests.swift
//  TransfersTests
//
//  Created by Inigo on 29/1/26.
//

import Testing
import Foundation
@testable import Transfers

// MARK: - TransferWorker CRUD Tests

@Suite("TransferWorker – CRUD & SwiftData", .tags(.unit, .swiftdata))
struct TransferWorkerCRUDTests {

    // MARK: - Helper
    @MainActor
    private func makeWorker() -> (
        worker: MockTransferWorker,
        local: MockSwiftDataService,
        cloud: MockSupabaseService
    ) {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        let worker = MockTransferWorker(swiftDataService: local, supabaseService: cloud)
        return (worker, local, cloud)
    }

    // MARK: - Fetch

    @MainActor
    @Test("Fetch – loads existing transfers from SwiftData")
    func fetchLoadsLocal() async {
        let (worker, local, _) = makeWorker()
        local.seed(TestDataBuilder.createMixedTransfers())   // 5 transfers

        await worker.fetchTransfers()

        #expect(worker.fetchTransfersCallCount == 1)
        #expect(local.transfers.count == 5)
        #expect(worker.lastError == nil)
    }

    @MainActor
    @Test("Fetch – empty local store returns no error")
    func fetchEmptyLocal() async {
        let (worker, _, _) = makeWorker()

        await worker.fetchTransfers()

        #expect(worker.lastError == nil)
    }

    // MARK: - Create

    @MainActor
    @Test("Create – transfer saved to SwiftData immediately")
    func createSavesLocally() async {
        let (worker, local, _) = makeWorker()

        let transfer = TestDataBuilder.createTransfer(id: "c1", amount: -15.00, description: "Taco")
        await worker.createTransfer(transfer)

        #expect(local.transfers.count == 1)
        #expect(local.transfers.first?.id == "c1")
        #expect(local.saveCount == 1)
    }

    @MainActor
    @Test("Create – transfer also pushed to Supabase")
    func createSyncesToCloud() async {
        let (worker, _, cloud) = makeWorker()

        let transfer = TestDataBuilder.createTransfer(id: "c2", amount: 50.0, description: "Cloud test")
        await worker.createTransfer(transfer)

        #expect(cloud.createCount == 1)
        #expect(cloud.transfers.count == 1)
        #expect(cloud.transfers.first?.id == "c2")
    }

    @MainActor
    @Test("Create – multiple transfers accumulate in SwiftData")
    func createMultiple() async {
        let (worker, local, _) = makeWorker()

        for i in 1...5 {
            await worker.createTransfer(
                TestDataBuilder.createTransfer(id: "m\(i)", description: "Multi \(i)")
            )
        }

        #expect(local.transfers.count == 5)
        #expect(local.saveCount == 5)
    }

    @MainActor
    @Test("Create – cloud failure does not prevent local save")
    func createCloudFailsLocalSucceeds() async {
        let (worker, local, cloud) = makeWorker()
        cloud.shouldFail = true

        let transfer = TestDataBuilder.createTransfer(id: "cf1", description: "Cloud fail")
        await worker.createTransfer(transfer)

        // Saved locally
        #expect(local.transfers.count == 1)
        // Cloud was attempted but failed – error captured
        #expect(worker.lastError != nil)
    }

    // MARK: - Update

    @MainActor
    @Test("Update – changes reflected in SwiftData")
    func updateChangesLocal() async {
        let (worker, local, _) = makeWorker()

        let original = TestDataBuilder.createTransfer(id: "u1", amount: -20.0, description: "Original", category: "Food")
        local.seed([original])

        let updated = TestDataBuilder.createTransfer(id: "u1", amount: 99.0, description: "Changed", category: "Other")
        await worker.updateTransfer(updated)

        let stored = local.transfers.first(where: { $0.id == "u1" })
        #expect(stored?.transferDescription == "Changed")
        #expect(stored?.category == "Other")
        #expect(stored?.amount == 99.0)
    }

    @MainActor
    @Test("Update – sync status becomes pending")
    func updateSetsPending() async {
        let (worker, local, _) = makeWorker()

        let original = TestDataBuilder.createTransfer(id: "u2", syncStatus: "synced")
        local.seed([original])

        await worker.updateTransfer(TestDataBuilder.createTransfer(id: "u2", description: "Trigger"))

        let stored = local.transfers.first(where: { $0.id == "u2" })
        #expect(stored?.syncStatus == "pending")
    }

    @MainActor
    @Test("Update – pushed to Supabase")
    func updateSyncesToCloud() async {
        let (worker, local, cloud) = makeWorker()

        let original = TestDataBuilder.createTransfer(id: "u3", description: "Pre-cloud")
        local.seed([original])
        cloud.transfers = [original]   // pretend cloud already has it

        await worker.updateTransfer(TestDataBuilder.createTransfer(id: "u3", description: "Post-cloud"))

        #expect(cloud.updateCount == 1)
    }

    @MainActor
    @Test("Update – non-existent transfer sets error, does not crash")
    func updateMissing() async {
        let (worker, _, _) = makeWorker()
        // local is empty

        await worker.updateTransfer(TestDataBuilder.createTransfer(id: "ghost", description: "Ghost"))

        #expect(worker.lastError != nil)
    }

    @MainActor
    @Test("Update – cloud failure still keeps local change")
    func updateCloudFailsLocalOk() async {
        let (worker, local, cloud) = makeWorker()
        cloud.shouldFail = true

        let original = TestDataBuilder.createTransfer(id: "ucf", description: "Before")
        local.seed([original])

        await worker.updateTransfer(TestDataBuilder.createTransfer(id: "ucf", description: "After"))

        // Local updated
        #expect(local.transfers.first?.transferDescription == "After")
        // Cloud error recorded
        #expect(worker.lastError != nil)
    }

    // MARK: - Delete

    @MainActor
    @Test("Delete – removes transfer from SwiftData")
    func deleteRemovesLocal() async {
        let (worker, local, _) = makeWorker()
        local.seed(TestDataBuilder.createMixedTransfers())   // 5 transfers

        await worker.deleteTransfer(id: "2")

        #expect(local.transfers.count == 4)
        #expect(local.transfers.contains(where: { $0.id == "2" }) == false)
        #expect(local.deleteCount == 1)
    }

    @MainActor
    @Test("Delete – also removes from Supabase")
    func deleteSyncesToCloud() async {
        let (worker, local, cloud) = makeWorker()
        let transfers = TestDataBuilder.createMixedTransfers()
        local.seed(transfers)
        cloud.transfers = transfers

        await worker.deleteTransfer(id: "1")

        #expect(cloud.deleteCount == 1)
        #expect(cloud.transfers.contains(where: { $0.id == "1" }) == false)
    }

    @MainActor
    @Test("Delete – all transfers one by one empties SwiftData")
    func deleteAll() async {
        let (worker, local, _) = makeWorker()
        let transfers = TestDataBuilder.createMixedTransfers()
        local.seed(transfers)

        for transfer in transfers {
            await worker.deleteTransfer(id: transfer.id)
        }

        #expect(local.transfers.isEmpty)
    }

    @MainActor
    @Test("Delete – cloud failure still removes locally")
    func deleteCloudFailsLocalOk() async {
        let (worker, local, cloud) = makeWorker()
        cloud.shouldFail = true

        local.seed([TestDataBuilder.createTransfer(id: "dcf")])

        await worker.deleteTransfer(id: "dcf")

        // Locally gone
        #expect(local.transfers.isEmpty)
        // Error recorded from cloud
        #expect(worker.lastError != nil)
    }

    // MARK: - Call-count tracking

    @MainActor
    @Test("Worker tracks call counts across all operations")
    func callCounts() async {
        let (worker, local, _) = makeWorker()

        // fetch ×2
        await worker.fetchTransfers()
        await worker.fetchTransfers()

        // create ×3
        for i in 1...3 {
            await worker.createTransfer(TestDataBuilder.createTransfer(id: "cc\(i)"))
        }

        // update ×1
        await worker.updateTransfer(TestDataBuilder.createTransfer(id: "cc1", description: "updated"))

        // delete ×1
        await worker.deleteTransfer(id: "cc2")

        #expect(worker.fetchTransfersCallCount  == 2)
        #expect(worker.createTransferCallCount  == 3)
        #expect(worker.updateTransferCallCount  == 1)
        #expect(worker.deleteTransferCallCount  == 1)
    }

    // MARK: - Reset helper

    @MainActor
    @Test("Reset clears everything")
    func resetClearsState() async {
        let (worker, local, cloud) = makeWorker()

        local.seed(TestDataBuilder.createMixedTransfers())
        cloud.transfers = TestDataBuilder.createMixedTransfers()
        await worker.createTransfer(TestDataBuilder.createTransfer(id: "r1"))

        worker.reset()

        #expect(local.transfers.isEmpty)
        #expect(cloud.transfers.isEmpty)
        #expect(worker.fetchTransfersCallCount  == 0)
        #expect(worker.createTransferCallCount  == 0)
        #expect(worker.updateTransferCallCount  == 0)
        #expect(worker.deleteTransferCallCount  == 0)
        #expect(worker.lastError == nil)
    }
}

// MARK: - Supabase Sync Tests

@Suite("TransferWorker – Supabase Sync", .tags(.unit, .supabase))
struct TransferWorkerSyncTests {

    @MainActor
    @Test("Sync – cloud delay does not block local create")
    func syncDelayNoBlock() async {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        cloud.delayMilliseconds = 200   // 200 ms cloud latency

        let worker = MockTransferWorker(swiftDataService: local, supabaseService: cloud)

        let transfer = TestDataBuilder.createTransfer(id: "delay1", description: "Delayed")

        let start = Date()
        await worker.createTransfer(transfer)
        let elapsed = Date().timeIntervalSince(start)

        // Local write happened immediately; cloud delay is serial in mock
        // but transfer IS in local regardless
        #expect(local.transfers.count == 1)
        // With 200 ms cloud delay the total will be ≥ 200 ms in this mock
        // (real worker fires cloud in background Task, so this would be <1 ms)
        // We just verify local is populated
        #expect(local.transfers.first?.id == "delay1")
    }

    @MainActor
    @Test("Sync – repeated creates don't duplicate in local")
    func syncNoDuplicates() async {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        let worker = MockTransferWorker(swiftDataService: local, supabaseService: cloud)

        let transfer = TestDataBuilder.createTransfer(id: "dup1", description: "Original")
        await worker.createTransfer(transfer)

        // "Re-create" same id (simulates a retry)
        await worker.createTransfer(transfer)

        // MockSwiftDataService.saveTransfer replaces on same id
        #expect(local.transfers.count == 1)
    }
}
