import Foundation
import SwiftData

/// Manages notes with offline-first architecture
/// Saves to SwiftData immediately, syncs to Supabase in background
@MainActor
@Observable
class NoteWorker {
    private let swiftDataService: SwiftDataService
    private let supabaseService: SupabaseService
    
    var isLoading = false
    var isSyncing = false
    var lastError: String?
    
    init(
        swiftDataService: SwiftDataService,
        supabaseService: SupabaseService
    ) {
        self.swiftDataService = swiftDataService
        self.supabaseService = supabaseService
    }
    
    // MARK: - 📥 Fetch Notes (Offline-First)
    
    /// Fetch notes - loads from local, then syncs from cloud
    func fetchNotes() async {
        isLoading = true
        lastError = nil
        
        do {
            // Sync from cloud - SwiftData will update automatically
            await syncFromCloud()
            
            let count = try swiftDataService.fetchNotes().count
            print("✅ \(count) notes available in SwiftData")
            
        } catch {
            lastError = "Failed to load notes: \(error.localizedDescription)"
            print("❌ Error loading notes: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - ➕ Create Note
    
    /// Create note - saves locally immediately, syncs to cloud
    func createNote(_ note: Note) async {
        do {
            // Save to SwiftData immediately (offline-first)
            try swiftDataService.saveNote(note)
            print("✅ Note saved locally: \(note.id)")
            
            // Sync to Supabase in background
            Task {
                await syncNoteToCloud(note)
            }
            
        } catch {
            lastError = "Failed to create note: \(error.localizedDescription)"
            print("❌ Error creating note: \(error)")
        }
    }
    
    // MARK: - ✏️ Update Note
    
    /// Update note - fetches from DB, updates, saves, syncs
    func updateNote(_ updatedNote: Note) async {
        do {
            // Fetch existing note from SwiftData
            guard let existingNote = try? swiftDataService.fetchNote(id: updatedNote.id) else {
                print("⚠️ Note not found for update: \(updatedNote.id)")
                lastError = "Note not found"
                return
            }
            
            // Update properties
            existingNote.amount = updatedNote.amount
            existingNote.noteDescription = updatedNote.noteDescription
            existingNote.category = updatedNote.category
            existingNote.markForSync()
            
            // Save to SwiftData
            try swiftDataService.updateNote(existingNote)
            print("✅ Note updated locally: \(existingNote.id)")
            
            // Sync to Supabase in background
            Task {
                await syncNoteToCloud(existingNote)
            }
            
        } catch {
            lastError = "Failed to update note: \(error.localizedDescription)"
            print("❌ Error updating note: \(error)")
        }
    }
    
    // MARK: - 🗑️ Delete Note
    
    /// Delete note - removes locally immediately, syncs to cloud
    func deleteNote(id: String) async {
        do {
            // Delete from SwiftData
            try swiftDataService.deleteNote(id: id)
            print("✅ Note deleted locally: \(id)")
            
            // Delete from Supabase in background
            Task {
                do {
                    try await supabaseService.deleteNote(id: id)
                    print("✅ Note deleted from cloud: \(id)")
                } catch {
                    print("⚠️ Failed to delete from cloud: \(error)")
                }
            }
            
        } catch {
            lastError = "Failed to delete note: \(error.localizedDescription)"
            print("❌ Error deleting note: \(error)")
        }
    }
    
    // MARK: - 🔄 Sync Methods
    
    /// Sync from Supabase to local SwiftData
    private func syncFromCloud() async {
        guard !isSyncing else { return }
        isSyncing = true
        
        do {
            // Fetch from Supabase
            let cloudNotes = try await supabaseService.fetchNotes()
            print("📥 Fetched \(cloudNotes.count) notes from cloud")
            
            // Merge with local notes
            for cloudNote in cloudNotes {
                if let localNote = try? swiftDataService.fetchNote(id: cloudNote.id) {
                    // Update if cloud is newer
                    if cloudNote.updatedAt > localNote.updatedAt {
                        try swiftDataService.deleteNote(id: localNote.id)
                        try swiftDataService.saveNote(cloudNote)
                    }
                } else {
                    // New note from cloud
                    try swiftDataService.saveNote(cloudNote)
                }
            }
            
            let finalCount = try swiftDataService.fetchNotes().count
            print("✅ Sync complete: \(finalCount) notes")
            
        } catch {
            print("⚠️ Sync from cloud failed: \(error)")
        }
        
        isSyncing = false
    }
    
    /// Sync single note to Supabase
    private func syncNoteToCloud(_ note: Note) async {
        do {
            // Check if exists in cloud
            let cloudNotes = try await supabaseService.fetchNotes()
            let exists = cloudNotes.contains { $0.id == note.id }
            
            if exists {
                // Update
                try await supabaseService.updateNote(note)
                print("✅ Note updated in cloud: \(note.id)")
            } else {
                // Create
                try await supabaseService.createNote(note)
                print("✅ Note created in cloud: \(note.id)")
            }
            
            // Mark as synced
            note.markAsSynced()
            try swiftDataService.updateNote(note)
            
        } catch {
            // Mark as failed
            note.markAsFailed()
            try? swiftDataService.updateNote(note)
            print("❌ Failed to sync to cloud: \(error)")
        }
    }
    
    /// Sync all pending notes to cloud
    func syncPendingNotes() async {
        do {
            let pending = try swiftDataService.fetchPendingNotes()
            print("🔄 Syncing \(pending.count) pending notes...")
            
            for note in pending {
                await syncNoteToCloud(note)
            }
            
            print("✅ Pending sync complete")
        } catch {
            print("❌ Failed to sync pending: \(error)")
        }
    }
    
    // MARK: - 🔍 Search & Filter
    
    func searchNotes(query: String) async throws -> [Note] {
        return try swiftDataService.searchNotes(query: query)
    }
    
    func filterByCategory(category: String) async throws -> [Note] {
        return try swiftDataService.fetchNotesByCategory(category: category)
    }
}
