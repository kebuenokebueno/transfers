import Foundation
import SwiftData

/// Manages notes with offline-first architecture
/// Saves to SwiftData immediately, syncs to Supabase in background
@MainActor
@Observable
class NoteManager {
    private let swiftDataService: SwiftDataService
    private let supabaseService: SupabaseService
    
    var notes: [Note] = []
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
    
    /// Fetch notes - tries local first, then syncs from cloud
    func fetchNotes() async {
        isLoading = true
        lastError = nil
        
        do {
            // 1. Load from local SwiftData first (instant)
            notes = try swiftDataService.fetchNotes()
            print("✅ Loaded \(notes.count) notes from local storage")
            
            // 2. Sync from Supabase in background
            await syncFromCloud()
            
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
            // 1. Save to SwiftData immediately (offline-first)
            try swiftDataService.saveNote(note)
            notes.insert(note, at: 0)
            print("✅ Note saved locally: \(note.id)")
            
            // 2. Sync to Supabase in background
            Task {
                await syncNoteToCloud(note)
            }
            
        } catch {
            lastError = "Failed to create note: \(error.localizedDescription)"
            print("❌ Error creating note: \(error)")
        }
    }
    
    // MARK: - ✏️ Update Note
    
    /// Update note - saves locally immediately, syncs to cloud
    func updateNote(_ note: Note) async {
        do {
            // 1. Update in SwiftData
            note.markForSync()
            try swiftDataService.updateNote(note)
            
            // Update local array
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
            
            print("✅ Note updated locally: \(note.id)")
            
            // 2. Sync to Supabase in background
            Task {
                await syncNoteToCloud(note)
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
            // 1. Delete from SwiftData
            try swiftDataService.deleteNote(id: id)
            notes.removeAll { $0.id == id }
            print("✅ Note deleted locally: \(id)")
            
            // 2. Delete from Supabase in background
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
            
            // Reload from local storage
            notes = try swiftDataService.fetchNotes()
            print("✅ Sync complete: \(notes.count) notes")
            
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
    
    func searchNotes(query: String) async {
        do {
            notes = try swiftDataService.searchNotes(query: query)
        } catch {
            lastError = "Search failed: \(error.localizedDescription)"
        }
    }
    
    func filterByCategory(category: String) async {
        do {
            notes = try swiftDataService.fetchNotesByCategory(category: category)
        } catch {
            lastError = "Filter failed: \(error.localizedDescription)"
        }
    }
    
    func resetFilter() async {
        await fetchNotes()
    }
    
    // MARK: - 📊 Statistics
    
    func getStatistics() async -> NoteStatistics? {
        do {
            return try swiftDataService.fetchStatistics()
        } catch {
            lastError = "Failed to get statistics: \(error.localizedDescription)"
            return nil
        }
    }
}
