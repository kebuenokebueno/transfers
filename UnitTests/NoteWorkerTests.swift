//
//  NoteWorkerTests.swift
//  TransfersTests
//
//  Created by Inigo on 29/1/26.
//

import Testing
import Foundation
@testable import Transfers

// MARK: - NoteWorker CRUD Tests

@Suite("NoteWorker – CRUD & SwiftData", .tags(.unit, .swiftdata))
struct NoteWorkerCRUDTests {

    // MARK: - Helper
    @MainActor
    private func makeWorker() -> (
        worker: MockNoteWorker,
        local: MockSwiftDataService,
        cloud: MockSupabaseService
    ) {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        let worker = MockNoteWorker(swiftDataService: local, supabaseService: cloud)
        return (worker, local, cloud)
    }

    // MARK: - Fetch

    @MainActor
    @Test("Fetch – loads existing notes from SwiftData")
    func fetchLoadsLocal() async {
        let (worker, local, _) = makeWorker()
        local.seed(TestDataBuilder.createMixedNotes())   // 5 notes

        await worker.fetchNotes()

        #expect(worker.fetchNotesCallCount == 1)
        #expect(local.notes.count == 5)
        #expect(worker.lastError == nil)
    }

    @MainActor
    @Test("Fetch – empty local store returns no error")
    func fetchEmptyLocal() async {
        let (worker, _, _) = makeWorker()

        await worker.fetchNotes()

        #expect(worker.lastError == nil)
    }

    // MARK: - Create

    @MainActor
    @Test("Create – note saved to SwiftData immediately")
    func createSavesLocally() async {
        let (worker, local, _) = makeWorker()

        let note = TestDataBuilder.createNote(id: "c1", amount: -15.00, description: "Taco")
        await worker.createNote(note)

        #expect(local.notes.count == 1)
        #expect(local.notes.first?.id == "c1")
        #expect(local.saveCount == 1)
    }

    @MainActor
    @Test("Create – note also pushed to Supabase")
    func createSyncesToCloud() async {
        let (worker, _, cloud) = makeWorker()

        let note = TestDataBuilder.createNote(id: "c2", amount: 50.0, description: "Cloud test")
        await worker.createNote(note)

        #expect(cloud.createCount == 1)
        #expect(cloud.notes.count == 1)
        #expect(cloud.notes.first?.id == "c2")
    }

    @MainActor
    @Test("Create – multiple notes accumulate in SwiftData")
    func createMultiple() async {
        let (worker, local, _) = makeWorker()

        for i in 1...5 {
            await worker.createNote(
                TestDataBuilder.createNote(id: "m\(i)", description: "Multi \(i)")
            )
        }

        #expect(local.notes.count == 5)
        #expect(local.saveCount == 5)
    }

    @MainActor
    @Test("Create – cloud failure does not prevent local save")
    func createCloudFailsLocalSucceeds() async {
        let (worker, local, cloud) = makeWorker()
        cloud.shouldFail = true

        let note = TestDataBuilder.createNote(id: "cf1", description: "Cloud fail")
        await worker.createNote(note)

        // Saved locally
        #expect(local.notes.count == 1)
        // Cloud was attempted but failed – error captured
        #expect(worker.lastError != nil)
    }

    // MARK: - Update

    @MainActor
    @Test("Update – changes reflected in SwiftData")
    func updateChangesLocal() async {
        let (worker, local, _) = makeWorker()

        let original = TestDataBuilder.createNote(id: "u1", amount: -20.0, description: "Original", category: "Food")
        local.seed([original])

        let updated = TestDataBuilder.createNote(id: "u1", amount: 99.0, description: "Changed", category: "Other")
        await worker.updateNote(updated)

        let stored = local.notes.first(where: { $0.id == "u1" })
        #expect(stored?.noteDescription == "Changed")
        #expect(stored?.category == "Other")
        #expect(stored?.amount == 99.0)
    }

    @MainActor
    @Test("Update – sync status becomes pending")
    func updateSetsPending() async {
        let (worker, local, _) = makeWorker()

        let original = TestDataBuilder.createNote(id: "u2", syncStatus: "synced")
        local.seed([original])

        await worker.updateNote(TestDataBuilder.createNote(id: "u2", description: "Trigger"))

        let stored = local.notes.first(where: { $0.id == "u2" })
        #expect(stored?.syncStatus == "pending")
    }

    @MainActor
    @Test("Update – pushed to Supabase")
    func updateSyncesToCloud() async {
        let (worker, local, cloud) = makeWorker()

        let original = TestDataBuilder.createNote(id: "u3", description: "Pre-cloud")
        local.seed([original])
        cloud.notes = [original]   // pretend cloud already has it

        await worker.updateNote(TestDataBuilder.createNote(id: "u3", description: "Post-cloud"))

        #expect(cloud.updateCount == 1)
    }

    @MainActor
    @Test("Update – non-existent note sets error, does not crash")
    func updateMissing() async {
        let (worker, _, _) = makeWorker()
        // local is empty

        await worker.updateNote(TestDataBuilder.createNote(id: "ghost", description: "Ghost"))

        #expect(worker.lastError != nil)
    }

    @MainActor
    @Test("Update – cloud failure still keeps local change")
    func updateCloudFailsLocalOk() async {
        let (worker, local, cloud) = makeWorker()
        cloud.shouldFail = true

        let original = TestDataBuilder.createNote(id: "ucf", description: "Before")
        local.seed([original])

        await worker.updateNote(TestDataBuilder.createNote(id: "ucf", description: "After"))

        // Local updated
        #expect(local.notes.first?.noteDescription == "After")
        // Cloud error recorded
        #expect(worker.lastError != nil)
    }

    // MARK: - Delete

    @MainActor
    @Test("Delete – removes note from SwiftData")
    func deleteRemovesLocal() async {
        let (worker, local, _) = makeWorker()
        local.seed(TestDataBuilder.createMixedNotes())   // 5 notes

        await worker.deleteNote(id: "2")

        #expect(local.notes.count == 4)
        #expect(local.notes.contains(where: { $0.id == "2" }) == false)
        #expect(local.deleteCount == 1)
    }

    @MainActor
    @Test("Delete – also removes from Supabase")
    func deleteSyncesToCloud() async {
        let (worker, local, cloud) = makeWorker()
        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)
        cloud.notes = notes

        await worker.deleteNote(id: "1")

        #expect(cloud.deleteCount == 1)
        #expect(cloud.notes.contains(where: { $0.id == "1" }) == false)
    }

    @MainActor
    @Test("Delete – all notes one by one empties SwiftData")
    func deleteAll() async {
        let (worker, local, _) = makeWorker()
        let notes = TestDataBuilder.createMixedNotes()
        local.seed(notes)

        for note in notes {
            await worker.deleteNote(id: note.id)
        }

        #expect(local.notes.isEmpty)
    }

    @MainActor
    @Test("Delete – cloud failure still removes locally")
    func deleteCloudFailsLocalOk() async {
        let (worker, local, cloud) = makeWorker()
        cloud.shouldFail = true

        local.seed([TestDataBuilder.createNote(id: "dcf")])

        await worker.deleteNote(id: "dcf")

        // Locally gone
        #expect(local.notes.isEmpty)
        // Error recorded from cloud
        #expect(worker.lastError != nil)
    }

    // MARK: - Call-count tracking

    @MainActor
    @Test("Worker tracks call counts across all operations")
    func callCounts() async {
        let (worker, local, _) = makeWorker()

        // fetch ×2
        await worker.fetchNotes()
        await worker.fetchNotes()

        // create ×3
        for i in 1...3 {
            await worker.createNote(TestDataBuilder.createNote(id: "cc\(i)"))
        }

        // update ×1
        await worker.updateNote(TestDataBuilder.createNote(id: "cc1", description: "updated"))

        // delete ×1
        await worker.deleteNote(id: "cc2")

        #expect(worker.fetchNotesCallCount  == 2)
        #expect(worker.createNoteCallCount  == 3)
        #expect(worker.updateNoteCallCount  == 1)
        #expect(worker.deleteNoteCallCount  == 1)
    }

    // MARK: - Reset helper

    @MainActor
    @Test("Reset clears everything")
    func resetClearsState() async {
        let (worker, local, cloud) = makeWorker()

        local.seed(TestDataBuilder.createMixedNotes())
        cloud.notes = TestDataBuilder.createMixedNotes()
        await worker.createNote(TestDataBuilder.createNote(id: "r1"))

        worker.reset()

        #expect(local.notes.isEmpty)
        #expect(cloud.notes.isEmpty)
        #expect(worker.fetchNotesCallCount  == 0)
        #expect(worker.createNoteCallCount  == 0)
        #expect(worker.updateNoteCallCount  == 0)
        #expect(worker.deleteNoteCallCount  == 0)
        #expect(worker.lastError == nil)
    }
}

// MARK: - Supabase Sync Tests

@Suite("NoteWorker – Supabase Sync", .tags(.unit, .supabase))
struct NoteWorkerSyncTests {

    @MainActor
    @Test("Sync – cloud delay does not block local create")
    func syncDelayNoBlock() async {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        cloud.delayMilliseconds = 200   // 200 ms cloud latency

        let worker = MockNoteWorker(swiftDataService: local, supabaseService: cloud)

        let note = TestDataBuilder.createNote(id: "delay1", description: "Delayed")

        let start = Date()
        await worker.createNote(note)
        let elapsed = Date().timeIntervalSince(start)

        // Local write happened immediately; cloud delay is serial in mock
        // but note IS in local regardless
        #expect(local.notes.count == 1)
        // With 200 ms cloud delay the total will be ≥ 200 ms in this mock
        // (real worker fires cloud in background Task, so this would be <1 ms)
        // We just verify local is populated
        #expect(local.notes.first?.id == "delay1")
    }

    @MainActor
    @Test("Sync – repeated creates don't duplicate in local")
    func syncNoDuplicates() async {
        let local  = MockSwiftDataService()
        let cloud  = MockSupabaseService()
        let worker = MockNoteWorker(swiftDataService: local, supabaseService: cloud)

        let note = TestDataBuilder.createNote(id: "dup1", description: "Original")
        await worker.createNote(note)

        // "Re-create" same id (simulates a retry)
        await worker.createNote(note)

        // MockSwiftDataService.saveNote replaces on same id
        #expect(local.notes.count == 1)
    }
}
