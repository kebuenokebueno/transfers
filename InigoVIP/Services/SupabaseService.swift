//
//  SupabaseService.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import Supabase


// MARK: - Supabase Service

@MainActor
@Observable
class SupabaseService {
    private let client: SupabaseClient
    
    // Status tracking
    var isConnected = false
    var lastError: String?
    
    init() {
        // Initialize Supabase client
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
        
        print("✅ Supabase initialized")
    }
    
    // MARK: - 📝 CRUD Operations
    
    /// Fetch all notes from Supabase
    func fetchNotes() async throws -> [NoteEntity] {
        print("📥 Fetching notes from Supabase...")
        
        let response: [NoteEntity] = try await client
            .from("notes")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        
        print("✅ Fetched \(response.count) notes")
        
        // Convert to Note model
        return response
    }
    
    /// Create a new note
    func createNote(_ note: NoteEntity) async throws {
        print("💾 Creating note: \(note.id)")
        
        try await client
            .from("notes")
            .insert(note)
            .execute()
        
        print("✅ Note created successfully")
    }
    
    /// Update an existing note
    func updateNote(_ note: NoteEntity) async throws {
        print("✏️ Updating note: \(note.id)")
        
        try await client
            .from("notes")
            .update(note)
            .eq("id", value: note.id)
            .execute()
        
        print("✅ Note updated successfully")
    }
    
    /// Delete a note
    func deleteNote(id: String) async throws {
        print("🗑️ Deleting note: \(id)")
        
        try await client
            .from("notes")
            .delete()
            .eq("id", value: id)
            .execute()
        
        print("✅ Note deleted successfully")
    }
    
    /// Fetch a single note by ID
    func fetchNote(id: String) async throws -> NoteEntity? {
        print("📥 Fetching note: \(id)")
        
        let response: [NoteEntity] = try await client
            .from("notes")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        return response.first
    }
    
    // MARK: - 🔍 Search & Filter
    
    /// Search notes by description
    func searchNotes(query: String) async throws -> [NoteEntity] {
        print("🔍 Searching notes: \(query)")
        
        let response: [NoteEntity] = try await client
            .from("notes")
            .select()
            .ilike("description", pattern: "%\(query)%")
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    /// Filter notes by category
    func fetchNotesByCategory(category: String) async throws -> [NoteEntity] {
        print("📂 Fetching notes for category: \(category)")
        
        let response: [NoteEntity] = try await client
            .from("notes")
            .select()
            .eq("category", value: category)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    /// Filter notes by date range
    func fetchNotesByDateRange(from: Date, to: Date) async throws -> [NoteEntity] {
        print("📅 Fetching notes from \(from) to \(to)")
        
        let response: [NoteEntity] = try await client
            .from("notes")
            .select()
            .gte("date", value: from.ISO8601Format())
            .lte("date", value: to.ISO8601Format())
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    // MARK: - 🔄 Test Connection
    
    func testConnection() async -> Bool {
        do {
            _ = try await fetchNotes()
            isConnected = true
            lastError = nil
            print("✅ Supabase connection successful")
            return true
        } catch {
            isConnected = false
            lastError = error.localizedDescription
            print("❌ Supabase connection failed: \(error)")
            return false
        }
    }
}

// MARK: - ⚠️ Error Handling

enum SupabaseError: Error, LocalizedError {
    case connectionFailed
    case notFound
    case invalidData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Failed to connect to Supabase"
        case .notFound:
            return "Note not found"
        case .invalidData:
            return "Invalid data format"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}
