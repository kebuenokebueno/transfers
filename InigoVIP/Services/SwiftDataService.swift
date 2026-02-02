import Foundation
import SwiftData

@MainActor
@Observable
class SwiftDataService {
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    init() {
        setupContainer()
    }
    
    // MARK: - Setup
    
    private func setupContainer() {
        let schema = Schema([Note.self])
        
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
    func saveNote(_ note: Note) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        context.insert(note)
        try context.save()
        
        print("💾 SwiftData: Note saved: \(note.id)")
    }
    
    /// Fetch all notes from local storage
    func fetchNotes() throws -> [Note] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch single note by ID
    func fetchNote(id: String) throws -> Note? {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.id == id }
        )
        
        return try context.fetch(descriptor).first
    }
    
    /// Update note in local storage
    func updateNote(_ note: Note) throws {
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
        
        let descriptor = FetchDescriptor<Note>(
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
    func searchNotes(query: String) throws -> [Note] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { note in
                note.noteDescription.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch notes by category
    func fetchNotesByCategory(category: String) throws -> [Note] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fetch notes that need syncing
    func fetchPendingNotes() throws -> [Note] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotAvailable
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.syncStatus == "pending" }
        )
        
        return try context.fetch(descriptor)
    }
    
    // MARK: - 📊 Statistics
    
    func fetchStatistics() throws -> NoteStatistics {
        let notes = try fetchNotes()
        
        let totalIncome = notes.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let totalExpenses = notes.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        let balance = totalIncome - totalExpenses
        
        return NoteStatistics(
            totalNotes: notes.count,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            balance: balance
        )
    }
}

// MARK: - Statistics Model

struct NoteStatistics {
    let totalNotes: Int
    let totalIncome: Double
    let totalExpenses: Double
    let balance: Double
}
