//
//  NoteListE2ETests.swift
//  InigoVIPTests
//
//  Created by Inigo on 4/2/26.
//


import Testing
import Foundation
import SwiftData
@testable import InigoVIP


@Suite("NoteList – E2E Tests", .tags(.e2e))
struct NoteListE2ETests {
    
    // MARK: - Setup
    
    @MainActor
    private func makeE2EStack() async throws -> (
        interactor: NoteListInteractor,
        presenter: NoteListPresenter,
        vc: MockNoteListViewController,
        worker: NoteWorker,
        swiftDataService: SwiftDataService,
        supabaseService: TestSupabaseService,
        container: ModelContainer
    ) {
        // SwiftData real (in-memory para no contaminar app)
        let container = try ModelContainer(
            for: Note.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let swiftDataService = SwiftDataService(modelContainer: container)
        let supabaseService = TestSupabaseService()
        
        // Limpiar datos de tests anteriores
        try await supabaseService.cleanupAllTestData()
        
        // Crear NoteWorker que usa TestSupabaseService
        // Necesitarás adaptar NoteWorker para aceptar el protocolo
        let worker = NoteWorker(
            swiftDataService: swiftDataService,
            supabaseService: supabaseService as! SupabaseService // Ver nota abajo
        )
        
        let interactor = NoteListInteractor(noteWorker: worker, swiftDataService: swiftDataService)
        let presenter = NoteListPresenter()
        let vc = MockNoteListViewController()
        
        interactor.presenter = presenter
        presenter.viewController = vc
        
        return (interactor, presenter, vc, worker, swiftDataService, supabaseService, container)
    }
    
    // MARK: - Connection Test
    
    @MainActor
    @Test("E2E: Supabase connection works")
    func e2eConnection() async throws {
        let supabase = TestSupabaseService()
        let connected = await supabase.testConnection()
        #expect(connected == true, "Supabase debe estar accesible para E2E tests")
    }
    
    // MARK: - Create
    
    @MainActor
    @Test("E2E: Create note syncs to Supabase")
    func e2eCreateNote() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()
        
        let container = try ModelContainer(
            for: Note.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let swiftDataService = SwiftDataService(modelContainer: container)
        
        // Crear nota
        let note = Note(
            id: "e2e_create_\(UUID().uuidString)",
            amount: -42.50,
            description: "E2E Test Note",
            date: Date(),
            category: "Food"
        )
        
        // Guardar local
        try swiftDataService.saveNote(note)
        
        // Sync a Supabase
        try await supabase.createNote(note)
        
        // Verificar en Supabase
        let cloudNotes = try await supabase.fetchNotes()
        #expect(cloudNotes.contains(where: { $0.id == note.id }))
        #expect(cloudNotes.first(where: { $0.id == note.id })?.noteDescription == "E2E Test Note")
        
        // Cleanup
        try await supabase.deleteNote(id: note.id)
    }
    
    // MARK: - Full Sync Cycle
    
    @MainActor
    @Test("E2E: Full sync cycle - local to cloud to local")
    func e2eFullSyncCycle() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()
        
        // Simular Device A - crea nota
        let noteId = "e2e_sync_\(UUID().uuidString)"
        let originalNote = Note(
            id: noteId,
            amount: -100.00,
            description: "Created on Device A",
            date: Date(),
            category: "Shopping"
        )
        
        try await supabase.createNote(originalNote)
        
        // Simular Device B - fetch desde cloud
        let container = try ModelContainer(
            for: Note.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let swiftDataService = SwiftDataService(modelContainer: container)
        
        let cloudNotes = try await supabase.fetchNotes()
        
        // Guardar en local de Device B
        for note in cloudNotes {
            try swiftDataService.saveNote(note)
        }
        
        // Verificar que Device B tiene la nota
        let localNotes = try swiftDataService.fetchNotes()
        #expect(localNotes.contains(where: { $0.id == noteId }))
        #expect(localNotes.first(where: { $0.id == noteId })?.noteDescription == "Created on Device A")
        
        // Cleanup
        try await supabase.cleanupAllTestData()
    }
    
    // MARK: - Update Sync
    
    @MainActor
    @Test("E2E: Update syncs correctly")
    func e2eUpdateSync() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()
        
        let noteId = "e2e_update_\(UUID().uuidString)"
        
        // Crear nota inicial
        let note = Note(
            id: noteId,
            amount: -50.00,
            description: "Original",
            date: Date(),
            category: "Food"
        )
        try await supabase.createNote(note)
        
        // Actualizar
        note.noteDescription = "Updated via E2E"
        note.amount = -75.00
        note.category = "Entertainment"
        try await supabase.updateNote(note)
        
        // Verificar
        let cloudNotes = try await supabase.fetchNotes()
        let updated = cloudNotes.first(where: { $0.id == noteId })
        
        #expect(updated != nil)
        #expect(updated?.noteDescription == "Updated via E2E")
        #expect(updated?.amount == -75.00)
        #expect(updated?.category == "Entertainment")
        
        // Cleanup
        try await supabase.cleanupAllTestData()
    }
    
    // MARK: - Delete Sync
    
    @MainActor
    @Test("E2E: Delete syncs correctly")
    func e2eDeleteSync() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()
        
        let noteId = "e2e_delete_\(UUID().uuidString)"
        
        // Crear
        let note = Note(
            id: noteId,
            amount: -25.00,
            description: "To be deleted",
            date: Date(),
            category: "Other"
        )
        try await supabase.createNote(note)
        
        // Verificar que existe
        var cloudNotes = try await supabase.fetchNotes()
        #expect(cloudNotes.contains(where: { $0.id == noteId }))
        
        // Eliminar
        try await supabase.deleteNote(id: noteId)
        
        // Verificar eliminación
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
        
        // Crear nota base
        let note = Note(
            id: noteId,
            amount: -100.00,
            description: "Original",
            date: Date(),
            category: "Food"
        )
        try await supabase.createNote(note)
        
        // Simular Device A actualiza
        note.noteDescription = "Device A update"
        note.updatedAt = Date()
        try await supabase.updateNote(note)
        
        // Simular Device B actualiza después (debería ganar)
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec
        note.noteDescription = "Device B update"
        note.updatedAt = Date()
        try await supabase.updateNote(note)
        
        // Verificar que Device B ganó
        let cloudNotes = try await supabase.fetchNotes()
        let final = cloudNotes.first(where: { $0.id == noteId })
        
        #expect(final?.noteDescription == "Device B update")
        
        // Cleanup
        try await supabase.cleanupAllTestData()
    }
    
    // MARK: - Bulk Operations
    
    @MainActor
    @Test("E2E: Bulk create and fetch")
    func e2eBulkOperations() async throws {
        let supabase = TestSupabaseService()
        try await supabase.cleanupAllTestData()
        
        // Crear múltiples notas
        let notes = (1...10).map { i in
            Note(
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
        
        // Fetch y verificar
        let cloudNotes = try await supabase.fetchNotes()
        
        #expect(cloudNotes.count >= 10)
        
        for note in notes {
            #expect(cloudNotes.contains(where: { $0.id == note.id }))
        }
        
        // Cleanup
        try await supabase.cleanupAllTestData()
    }
    
    // MARK: - Network Resilience
    
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
        let testDate = Date()
        
        let original = Note(
            id: noteId,
            amount: -123.45,
            description: "Integrity test with special chars: áéíóú 🎉",
            date: testDate,
            category: "Special Category"
        )
        
        try await supabase.createNote(original)
        
        let cloudNotes = try await supabase.fetchNotes()
        let fetched = cloudNotes.first(where: { $0.id == noteId })
        
        #expect(fetched != nil)
        #expect(fetched?.id == noteId)
        #expect(fetched?.amount == -123.45)
        #expect(fetched?.noteDescription == "Integrity test with special chars: áéíóú 🎉")
        #expect(fetched?.category == "Special Category")
        
        // Cleanup
        try await supabase.cleanupAllTestData()
    }
}
