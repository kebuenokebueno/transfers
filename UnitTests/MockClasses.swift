//
//  MockClasses.swift
//  InigoVIPTests
//
//  Created by Inigo on 29/1/26.
//

import Foundation
import Testing
import SwiftData
@testable import InigoVIP


// MARK: - Tags

extension Tag {
    @Tag static var unit: Self
    @Tag static var interactor: Self
    @Tag static var presenter: Self
    @Tag static var integration: Self
    @Tag static var performance: Self
    @Tag static var swiftdata: Self
    @Tag static var supabase: Self
}

// MARK: - Custom Error Types

enum NoteError: Error, Equatable {
    case notFound
    case saveFailed
    case deleteFailed
    case syncFailed
    case connectionFailed
    case timeout
}

// MARK: - Mock SwiftDataService

/// In-memory replacement for SwiftDataService — no ModelContext needed
class MockSwiftDataService: SwiftDataServiceProtocol {
    var notes: [Note] = []
    var saveCount = 0
    var updateCount = 0
    var deleteCount = 0
    var shouldFailOnSave = false
    var shouldFailOnDelete = false
    var shouldFailOnFetch = false

    func saveNote(_ note: Note) throws {
        saveCount += 1
        if shouldFailOnSave { throw NoteError.saveFailed }
        // Replace if same id exists, otherwise append
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes[idx] = note
        } else {
            notes.append(note)
        }
    }

    func fetchNotes() throws -> [Note] {
        if shouldFailOnFetch { throw NoteError.notFound }
        return notes.sorted { $0.date > $1.date }
    }

    func fetchNote(id: String) throws -> Note? {
        if shouldFailOnFetch { throw NoteError.notFound }
        return notes.first(where: { $0.id == id })
    }

    func updateNote(_ note: Note) throws {
        updateCount += 1
        if shouldFailOnSave { throw NoteError.saveFailed }
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else {
            throw NoteError.notFound
        }
        notes[idx] = note
    }

    func deleteNote(id: String) throws {
        deleteCount += 1
        if shouldFailOnDelete { throw NoteError.deleteFailed }
        guard notes.contains(where: { $0.id == id }) else {
            throw NoteError.notFound
        }
        notes.removeAll(where: { $0.id == id })
    }

    func searchNotes(query: String) throws -> [Note] {
        let q = query.lowercased()
        return notes.filter {
            $0.noteDescription.lowercased().contains(q) ||
            $0.category.lowercased().contains(q)
        }
    }

    func fetchNotesByCategory(category: String) throws -> [Note] {
        return notes.filter { $0.category == category }
    }

    func fetchPendingNotes() throws -> [Note] {
        return notes.filter { $0.syncStatus == "pending" }
    }

    // Helper to seed
    func seed(_ noteArray: [Note]) {
        notes = noteArray
    }

    func reset() {
        notes = []
        saveCount = 0
        updateCount = 0
        deleteCount = 0
        shouldFailOnSave = false
        shouldFailOnDelete = false
        shouldFailOnFetch = false
    }
}

// MARK: - Mock SupabaseService

/// Fake cloud — tracks what was pushed, never hits the network
class MockSupabaseService {
    var notes: [Note] = []
    var createCount = 0
    var updateCount = 0
    var deleteCount = 0
    var shouldFail = false
    var delayMilliseconds: UInt64 = 0

    func fetchNotes() async throws -> [Note] {
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        if shouldFail { throw NoteError.connectionFailed }
        return notes
    }

    func createNote(_ note: Note) async throws {
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        if shouldFail { throw NoteError.connectionFailed }
        createCount += 1
        notes.append(note)
    }

    func updateNote(_ note: Note) async throws {
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        if shouldFail { throw NoteError.connectionFailed }
        updateCount += 1
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes[idx] = note
        }
    }

    func deleteNote(id: String) async throws {
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        if shouldFail { throw NoteError.connectionFailed }
        deleteCount += 1
        notes.removeAll(where: { $0.id == id })
    }

    func reset() {
        notes = []
        createCount = 0
        updateCount = 0
        deleteCount = 0
        shouldFail = false
        delayMilliseconds = 0
    }
}

// MARK: - Mock NoteWorker

/// Mirrors NoteWorker behaviour using the two mocks above.
/// Every method matches the real NoteWorker signature so tests stay realistic.

class MockNoteWorker: NoteWorkerProtocol {
    let swiftDataService: MockSwiftDataService
    let supabaseService: MockSupabaseService

    var isLoading = false
    var isSyncing = false
    var lastError: String?

    // Call-count tracking
    var fetchNotesCallCount = 0
    var createNoteCallCount = 0
    var updateNoteCallCount = 0
    var deleteNoteCallCount = 0

    init(
        swiftDataService: MockSwiftDataService = MockSwiftDataService(),
        supabaseService: MockSupabaseService = MockSupabaseService()
    ) {
        self.swiftDataService = swiftDataService
        self.supabaseService = supabaseService
    }

    // MARK: - CRUD (mirrors NoteWorker)

    func fetchNotes() async {
        fetchNotesCallCount += 1
        isLoading = true
        lastError = nil
        do {
            _ = try swiftDataService.fetchNotes()
        } catch {
            lastError = error.localizedDescription
        }
        isLoading = false
    }

    func createNote(_ note: Note) async {
        createNoteCallCount += 1
        do {
            try swiftDataService.saveNote(note)
            // fire-and-forget cloud sync (same as real worker)
            try await supabaseService.createNote(note)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func updateNote(_ updatedNote: Note) async {
        updateNoteCallCount += 1
        do {
            guard let existing = try swiftDataService.fetchNote(id: updatedNote.id) else {
                lastError = "Note not found"
                return
            }
            existing.amount = updatedNote.amount
            existing.noteDescription = updatedNote.noteDescription
            existing.category = updatedNote.category
            existing.markForSync()
            try swiftDataService.updateNote(existing)
            try await supabaseService.updateNote(existing)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deleteNote(id: String) async {
        deleteNoteCallCount += 1
        do {
            try swiftDataService.deleteNote(id: id)
            try await supabaseService.deleteNote(id: id)
        } catch {
            lastError = error.localizedDescription
        }
    }

    // helpers
    func reset() {
        swiftDataService.reset()
        supabaseService.reset()
        fetchNotesCallCount = 0
        createNoteCallCount = 0
        updateNoteCallCount = 0
        deleteNoteCallCount = 0
        lastError = nil
    }
}

// MARK: - Mock Presenter  (captures what Interactor sends)


class MockNoteListPresenter: NotePresentationLogic {
    // Fetch
    var presentNotesCalled = false
    var presentNotesCallCount = 0
    var lastFetchResponse: NoteScene.FetchNotes.Response?

    // Create
    var presentCreateResultCalled = false
    var lastCreateResponse: NoteScene.CreateNote.Response?

    // Update
    var presentUpdateResultCalled = false
    var lastUpdateResponse: NoteScene.UpdateNote.Response?

    // Delete
    var presentDeleteResultCalled = false
    var lastDeleteResponse: NoteScene.DeleteNote.Response?

    // Single note
    var presentNoteCalled = false
    var lastNoteResponse: NoteScene.FetchNote.Response?

    func presentNotes(response: NoteScene.FetchNotes.Response) {
        presentNotesCalled = true
        presentNotesCallCount += 1
        lastFetchResponse = response
    }

    func presentCreateResult(response: NoteScene.CreateNote.Response) {
        presentCreateResultCalled = true
        lastCreateResponse = response
    }

    func presentUpdateResult(response: NoteScene.UpdateNote.Response) {
        presentUpdateResultCalled = true
        lastUpdateResponse = response
    }

    func presentDeleteResult(response: NoteScene.DeleteNote.Response) {
        presentDeleteResultCalled = true
        lastDeleteResponse = response
    }

    func presentNote(response: NoteScene.FetchNote.Response) {
        presentNoteCalled = true
        lastNoteResponse = response
    }
}

// MARK: - Mock ViewController (captures what Presenter sends)


class MockNoteListViewController: NoteDisplayLogic {
    var displayNotesCalled = false
    var displayNotesCallCount = 0
    var lastFetchViewModel: NoteScene.FetchNotes.ViewModel?

    var displayCreateResultCalled = false
    var lastCreateViewModel: NoteScene.CreateNote.ViewModel?

    var displayUpdateResultCalled = false
    var lastUpdateViewModel: NoteScene.UpdateNote.ViewModel?

    var displayDeleteResultCalled = false
    var lastDeleteViewModel: NoteScene.DeleteNote.ViewModel?

    var displayNoteCalled = false
    var lastNoteViewModel: NoteScene.FetchNote.ViewModel?

    func displayNotes(viewModel: NoteScene.FetchNotes.ViewModel) {
        displayNotesCalled = true
        displayNotesCallCount += 1
        lastFetchViewModel = viewModel
    }

    func displayCreateResult(viewModel: NoteScene.CreateNote.ViewModel) {
        displayCreateResultCalled = true
        lastCreateViewModel = viewModel
    }

    func displayUpdateResult(viewModel: NoteScene.UpdateNote.ViewModel) {
        displayUpdateResultCalled = true
        lastUpdateViewModel = viewModel
    }

    func displayDeleteResult(viewModel: NoteScene.DeleteNote.ViewModel) {
        displayDeleteResultCalled = true
        lastDeleteViewModel = viewModel
    }

    func displayNote(viewModel: NoteScene.FetchNote.ViewModel) {
        displayNoteCalled = true
        lastNoteViewModel = viewModel
    }
}

// MARK: - Test Data Builder

struct TestDataBuilder {
    static func createNote(
        id: String = "test_1",
        amount: Double = -100.0,
        description: String = "Test Note",
        date: Date = Date(),
        category: String = "Food",
        syncStatus: String = "pending"
    ) -> Note {
        Note(
            id: id,
            amount: amount,
            description: description,
            date: date,
            category: category,
            syncStatus: Note.SyncStatus(rawValue: syncStatus)!
        )
    }

    static func createNotes(count: Int) -> [Note] {
        (1...count).map { i in
            createNote(
                id: "note_\(i)",
                amount: (i % 3 == 0) ? Double(i * 100) : -Double(i * 10),
                description: "Note \(i)",
                category: ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"][i % 6]
            )
        }
    }

    /// 5 notes — mix of income / expense, every category represented
    static func createMixedNotes() -> [Note] {
        [
            createNote(id: "1", amount: -45.50,  description: "Grocery Store",  category: "Food"),
            createNote(id: "2", amount: -120.00, description: "Electric Bill",  category: "Utilities"),
            createNote(id: "3", amount: 2500.00, description: "Salary",         category: "Income"),
            createNote(id: "4", amount: -30.00,  description: "Gas Station",    category: "Transport"),
            createNote(id: "5", amount: 150.00,  description: "Freelance Work", category: "Income")
        ]
    }
}
