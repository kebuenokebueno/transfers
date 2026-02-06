import Foundation
import SwiftData

protocol SwiftDataServiceProtocol: AnyObject {
    func fetchNotes() throws -> [NoteEntity]
    func fetchNote(id: String) throws -> NoteEntity?
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
        let schema = Schema([NoteEntity.self])
        
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
    
    /// Save note to local storage
    func saveNote(_ note: NoteEntity) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        context.insert(note)
        try context.save()
        
        print("💾 SwiftData: Note saved: \(note.id)")
    }
    
    /// Fetch all notes from local storage
    func fetchNotes() throws -> [NoteEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<NoteEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch single note by ID
    func fetchNote(id: String) throws -> NoteEntity? {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<NoteEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        return try context.fetch(descriptor).first
    }
    
    /// Update note in local storage
    func updateNote(_ note: NoteEntity) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        note.updatedAt = Date()
        try context.save()
        
        print("✏️ SwiftData: Note updated: \(note.id)")
    }
    
    /// Delete note from local storage
    func deleteNote(id: String) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<NoteEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        if let note = try context.fetch(descriptor).first {
            context.delete(note)
            try context.save()
            print("🗑️ SwiftData: Note deleted: \(id)")
        }
    }
    
    /// Delete all notes
    func deleteAllNotes() throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let notes = try fetchNotes()
        for note in notes {
            context.delete(note)
        }
        try context.save()
        
        print("🗑️ SwiftData: All notes deleted")
    }
    
    // MARK: - 🔍 Search & Filter
    
    /// Search notes by description
    func searchNotes(query: String) throws -> [NoteEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<NoteEntity>(
            predicate: #Predicate { note in
                note.noteDescription.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch notes by category
    func fetchNotesByCategory(category: String) throws -> [NoteEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<NoteEntity>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch notes that need syncing
    func fetchPendingNotes() throws -> [NoteEntity] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<NoteEntity>(
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
