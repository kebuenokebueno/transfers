//
//  NoteListE2ETests.swift
//  InigoVIPTests
//

import Testing
import Foundation
import SwiftData
@testable import InigoVIP

@Suite("NoteList - E2E Tests", .tags(.e2e))
struct NoteListE2ETests {

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
    @Test("E2E: Create note syncs to Supabase")
    func e2eCreateNote() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let container = try ModelContainer(
            for: NoteEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let swiftDataService = SwiftDataService(modelContainer: container)

        let note = NoteEntity(
            id: "e2e_create_\(UUID().uuidString)",
            amount: -42.50,
            description: "E2E Test Note",
            date: Date(),
            category: "Food"
        )

        try swiftDataService.saveNote(note)
        try await supabase.createNote(note)

        let cloudNotes = try await supabase.fetchNotes()
        #expect(cloudNotes.contains(where: { $0.id == note.id }))
        #expect(cloudNotes.first(where: { $0.id == note.id })?.noteDescription == "E2E Test Note")

        try await supabase.deleteNote(id: note.id)
    }

    // MARK: - Full Sync Cycle

    @MainActor
    @Test("E2E: Full sync cycle - local to cloud to local")
    func e2eFullSyncCycle() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let noteId = "e2e_sync_\(UUID().uuidString)"
        let originalNote = NoteEntity(
            id: noteId,
            amount: -100.00,
            description: "Created on Device A",
            date: Date(),
            category: "Shopping"
        )

        try await supabase.createNote(originalNote)

        let container = try ModelContainer(
            for: NoteEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let swiftDataService = SwiftDataService(modelContainer: container)

        let cloudNotes = try await supabase.fetchNotes()
        for note in cloudNotes {
            try swiftDataService.saveNote(note)
        }

        let localNotes = try swiftDataService.fetchNotes()
        #expect(localNotes.contains(where: { $0.id == noteId }))
        #expect(localNotes.first(where: { $0.id == noteId })?.noteDescription == "Created on Device A")

        try await supabase.cleanupAllTestData()
    }

    // MARK: - Update Sync

    @MainActor
    @Test("E2E: Update syncs correctly")
    func e2eUpdateSync() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let noteId = "e2e_update_\(UUID().uuidString)"
        let note = NoteEntity(
            id: noteId,
            amount: -50.00,
            description: "Original",
            date: Date(),
            category: "Food"
        )
        try await supabase.createNote(note)

        note.noteDescription = "Updated via E2E"
        note.amount = -75.00
        note.category = "Entertainment"
        try await supabase.updateNote(note)

        let cloudNotes = try await supabase.fetchNotes()
        let updated = cloudNotes.first(where: { $0.id == noteId })
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

        let noteId = "e2e_delete_\(UUID().uuidString)"
        let note = NoteEntity(
            id: noteId,
            amount: -25.00,
            description: "To be deleted",
            date: Date(),
            category: "Other"
        )
        try await supabase.createNote(note)

        var cloudNotes = try await supabase.fetchNotes()
        #expect(cloudNotes.contains(where: { $0.id == noteId }))

        try await supabase.deleteNote(id: noteId)

        cloudNotes = try await supabase.fetchNotes()
        #expect(!cloudNotes.contains(where: { $0.id == noteId }))
    }

    // MARK: - Conflict Resolution

    @MainActor
    @Test("E2E: Last write wins on conflict")
    func e2eConflictResolution() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let noteId = "e2e_conflict_\(UUID().uuidString)"
        let note = NoteEntity(
            id: noteId,
            amount: -100.00,
            description: "Original",
            date: Date(),
            category: "Food"
        )
        try await supabase.createNote(note)

        note.noteDescription = "Device A update"
        note.updatedAt = Date()
        try await supabase.updateNote(note)

        try await Task.sleep(nanoseconds: 100_000_000)

        note.noteDescription = "Device B update"
        note.updatedAt = Date()
        try await supabase.updateNote(note)

        let cloudNotes = try await supabase.fetchNotes()
        let final = cloudNotes.first(where: { $0.id == noteId })
        #expect(final?.noteDescription == "Device B update")

        try await supabase.cleanupAllTestData()
    }

    // MARK: - Bulk Operations

    @MainActor
    @Test("E2E: Bulk create and fetch")
    func e2eBulkOperations() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let notes = (1...10).map { i in
            NoteEntity(
                id: "e2e_bulk_\(i)_\(UUID().uuidString)",
                amount: Double(-i * 10),
                description: "Bulk note \(i)",
                date: Date(),
                category: "Test"
            )
        }

        for note in notes {
            try await supabase.createNote(note)
        }

        let cloudNotes = try await supabase.fetchNotes()
        #expect(cloudNotes.count >= 10)
        for note in notes {
            #expect(cloudNotes.contains(where: { $0.id == note.id }))
        }

        try await supabase.cleanupAllTestData()
    }

    // MARK: - Empty Database

    @MainActor
    @Test("E2E: Handles empty database gracefully")
    func e2eEmptyDatabase() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()
        let notes = try await supabase.fetchNotes()
        #expect(notes.isEmpty)
    }

    // MARK: - Data Integrity

    @MainActor
    @Test("E2E: All fields persist correctly")
    func e2eDataIntegrity() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()

        let noteId = "e2e_integrity_\(UUID().uuidString)"
        let testDescription = "Integrity test with special chars: aeiou"

        let original = NoteEntity(
            id: noteId,
            amount: -123.45,
            description: testDescription,
            date: Date(),
            category: "Special Category"
        )

        try await supabase.createNote(original)

        let cloudNotes = try await supabase.fetchNotes()
        let fetched = cloudNotes.first(where: { $0.id == noteId })
        #expect(fetched != nil)
        #expect(fetched?.id == noteId)
        #expect(fetched?.amount == -123.45)
        #expect(fetched?.noteDescription == testDescription)
        #expect(fetched?.category == "Special Category")

        try await supabase.cleanupAllTestData()
    }
}
