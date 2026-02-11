//
//  MockClasses.swift
//  InigoVIPTests
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
    @Tag static var e2e: Self
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

class MockSwiftDataService: SwiftDataServiceProtocol {
    var notes: [NoteEntity] = []
    var saveCount = 0
    var updateCount = 0
    var deleteCount = 0
    var shouldFailOnSave = false
    var shouldFailOnDelete = false
    var shouldFailOnFetch = false

    func saveNote(_ note: NoteEntity) throws {
        saveCount += 1
        if shouldFailOnSave { throw NoteError.saveFailed }
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes[idx] = note
        } else {
            notes.append(note)
        }
    }

    func fetchNotes() throws -> [NoteEntity] {
        if shouldFailOnFetch { throw NoteError.notFound }
        return notes.sorted { $0.date > $1.date }
    }

    func fetchNote(id: String) throws -> NoteEntity? {
        if shouldFailOnFetch { throw NoteError.notFound }
        return notes.first(where: { $0.id == id })
    }

    func updateNote(_ note: NoteEntity) throws {
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

    func searchNotes(query: String) throws -> [NoteEntity] {
        let q = query.lowercased()
        return notes.filter {
            $0.noteDescription.lowercased().contains(q) ||
            $0.category.lowercased().contains(q)
        }
    }

    func fetchNotesByCategory(category: String) throws -> [NoteEntity] {
        return notes.filter { $0.category == category }
    }

    func fetchPendingNotes() throws -> [NoteEntity] {
        return notes.filter { $0.syncStatus == "pending" }
    }

    func seed(_ noteArray: [NoteEntity]) { notes = noteArray }

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

class MockSupabaseService {
    var notes: [NoteEntity] = []
    var createCount = 0
    var updateCount = 0
    var deleteCount = 0
    var shouldFail = false
    var delayMilliseconds: UInt64 = 0

    func fetchNotes() async throws -> [NoteEntity] {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
        if shouldFail { throw NoteError.connectionFailed }
        return notes
    }

    func createNote(_ note: NoteEntity) async throws {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
        if shouldFail { throw NoteError.connectionFailed }
        createCount += 1
        notes.append(note)
    }

    func updateNote(_ note: NoteEntity) async throws {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
        if shouldFail { throw NoteError.connectionFailed }
        updateCount += 1
        if let idx = notes.firstIndex(where: { $0.id == note.id }) { notes[idx] = note }
    }

    func deleteNote(id: String) async throws {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
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

class MockNoteWorker: NoteWorkerProtocol {
    let swiftDataService: MockSwiftDataService
    let supabaseService: MockSupabaseService

    var isLoading = false
    var lastError: String?

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

    func fetchNotes() async {
        fetchNotesCallCount += 1
        isLoading = true
        lastError = nil
        do { _ = try swiftDataService.fetchNotes() } catch { lastError = error.localizedDescription }
        isLoading = false
    }

    func createNote(_ note: NoteEntity) async {
        createNoteCallCount += 1
        do {
            try swiftDataService.saveNote(note)
            try await supabaseService.createNote(note)
        } catch { lastError = error.localizedDescription }
    }

    func updateNote(_ updatedNote: NoteEntity) async {
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
        } catch { lastError = error.localizedDescription }
    }

    func deleteNote(id: String) async {
        deleteNoteCallCount += 1
        do {
            try swiftDataService.deleteNote(id: id)
            try await supabaseService.deleteNote(id: id)
        } catch { lastError = error.localizedDescription }
    }

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

// MARK: - Mock NoteList Presenter

class MockNoteListPresenter: NoteListPresentationLogic {
    var presentNotesCalled = false
    var presentNotesCallCount = 0
    var lastFetchResponse: NoteScene.FetchNotes.Response?

    var presentDeleteResultCalled = false
    var lastDeleteResponse: NoteScene.DeleteNote.Response?

    func presentNotes(response: NoteScene.FetchNotes.Response) {
        presentNotesCalled = true
        presentNotesCallCount += 1
        lastFetchResponse = response
    }

    func presentDeleteResult(response: NoteScene.DeleteNote.Response) {
        presentDeleteResultCalled = true
        lastDeleteResponse = response
    }
}

// MARK: - Mock NoteList ViewController

class MockNoteListViewController: NoteListDisplayLogic {
    var displayNotesCalled = false
    var displayNotesCallCount = 0
    var lastFetchViewModel: NoteScene.FetchNotes.ViewModel?

    var displayDeleteResultCalled = false
    var lastDeleteViewModel: NoteScene.DeleteNote.ViewModel?

    func displayNotes(viewModel: NoteScene.FetchNotes.ViewModel) {
        displayNotesCalled = true
        displayNotesCallCount += 1
        lastFetchViewModel = viewModel
    }

    func displayDeleteResult(viewModel: NoteScene.DeleteNote.ViewModel) {
        displayDeleteResultCalled = true
        lastDeleteViewModel = viewModel
    }
}

// MARK: - Mock AddNote Presenter

class MockAddNotePresenter: AddNotePresentationLogic {
    var presentSaveResultCalled = false
    var lastSaveResponse: AddNoteScene.SaveNote.Response?

    func presentSaveResult(response: AddNoteScene.SaveNote.Response) {
        presentSaveResultCalled = true
        lastSaveResponse = response
    }
}

// MARK: - Mock AddNote ViewController

class MockAddNoteViewController: AddNoteDisplayLogic {
    var displaySaveResultCalled = false
    var lastSaveViewModel: AddNoteScene.SaveNote.ViewModel?

    func displaySaveResult(viewModel: AddNoteScene.SaveNote.ViewModel) {
        displaySaveResultCalled = true
        lastSaveViewModel = viewModel
    }
}

// MARK: - Mock EditNote Presenter

class MockEditNotePresenter: EditNotePresentationLogic {
    var presentNoteCalled = false
    var lastLoadResponse: EditNoteScene.LoadNote.Response?

    var presentSaveResultCalled = false
    var lastSaveResponse: EditNoteScene.SaveNote.Response?

    func presentNote(response: EditNoteScene.LoadNote.Response) {
        presentNoteCalled = true
        lastLoadResponse = response
    }

    func presentSaveResult(response: EditNoteScene.SaveNote.Response) {
        presentSaveResultCalled = true
        lastSaveResponse = response
    }
}

// MARK: - Mock EditNote ViewController

class MockEditNoteViewController: EditNoteDisplayLogic {
    var displayNoteCalled = false
    var lastNoteViewModel: EditNoteScene.LoadNote.ViewModel?

    var displaySaveResultCalled = false
    var lastSaveViewModel: EditNoteScene.SaveNote.ViewModel?

    func displayNote(viewModel: EditNoteScene.LoadNote.ViewModel) {
        displayNoteCalled = true
        lastNoteViewModel = viewModel
    }

    func displaySaveResult(viewModel: EditNoteScene.SaveNote.ViewModel) {
        displaySaveResultCalled = true
        lastSaveViewModel = viewModel
    }
}

// MARK: - Mock NoteDetail Presenter

class MockNoteDetailPresenter: NoteDetailPresentationLogic {
    var presentNoteCalled = false
    var lastFetchResponse: NoteDetailScene.FetchNote.Response?

    var presentDeleteResultCalled = false
    var lastDeleteResponse: NoteDetailScene.DeleteNote.Response?

    func presentNote(response: NoteDetailScene.FetchNote.Response) {
        presentNoteCalled = true
        lastFetchResponse = response
    }

    func presentDeleteResult(response: NoteDetailScene.DeleteNote.Response) {
        presentDeleteResultCalled = true
        lastDeleteResponse = response
    }
}

// MARK: - Mock NoteDetail ViewController

class MockNoteDetailViewController: NoteDetailDisplayLogic {
    var displayNoteCalled = false
    var lastNoteViewModel: NoteDetailScene.FetchNote.ViewModel?

    var displayDeleteResultCalled = false
    var lastDeleteViewModel: NoteDetailScene.DeleteNote.ViewModel?

    func displayNote(viewModel: NoteDetailScene.FetchNote.ViewModel) {
        displayNoteCalled = true
        lastNoteViewModel = viewModel
    }

    func displayDeleteResult(viewModel: NoteDetailScene.DeleteNote.ViewModel) {
        displayDeleteResultCalled = true
        lastDeleteViewModel = viewModel
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
    ) -> NoteEntity {
        NoteEntity(
            id: id,
            amount: amount,
            description: description,
            date: date,
            category: category,
            syncStatus: NoteEntity.SyncStatus(rawValue: syncStatus)!
        )
    }

    static func createNotes(count: Int) -> [NoteEntity] {
        (1...count).map { i in
            createNote(
                id: "note_\(i)",
                amount: (i % 3 == 0) ? Double(i * 100) : -Double(i * 10),
                description: "Note \(i)",
                category: ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"][i % 6]
            )
        }
    }

    static func createMixedNotes() -> [NoteEntity] {
        [
            createNote(id: "1", amount: -45.50,  description: "Grocery Store",  category: "Food"),
            createNote(id: "2", amount: -120.00, description: "Electric Bill",  category: "Utilities"),
            createNote(id: "3", amount: 2500.00, description: "Salary",         category: "Income"),
            createNote(id: "4", amount: -30.00,  description: "Gas Station",    category: "Transport"),
            createNote(id: "5", amount: 150.00,  description: "Freelance Work", category: "Income")
        ]
    }
}
