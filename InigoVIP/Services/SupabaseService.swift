//
//  SupabaseService.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import Supabase


// MARK: - Configuration

struct SupabaseConfig {
    // 🔧 REPLACE WITH YOUR SUPABASE PROJECT DETAILS
    static let supabaseURL = "https://yjetrepgnhxzlphvawwy.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlqZXRyZXBnbmh4emxwaHZhd3d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMDcwNzksImV4cCI6MjA3Njc4MzA3OX0.aaSuBJt4dZu2hW1wHVgRdCKCL0BvohmfyGgVGNFHvw4"
}

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
    func fetchNotes() async throws -> [Note] {
        print("📥 Fetching notes from Supabase...")
        
        let response: [SupabaseNote] = try await client
            .from("notes")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        
        print("✅ Fetched \(response.count) notes")
        
        // Convert to Note model
        return response.map { $0.toNote() }
    }
    
    /// Create a new note
    func createNote(_ note: Note) async throws {
        print("💾 Creating note: \(note.id)")
        
        let note = SupabaseNote(
            id: note.id,
            amount: note.amount,
            description: note.transactionDescription,
            date: note.date,
            category: note.category,
            thumbnail_url: note.thumbnailUrl
        )
        
        try await client
            .from("notes")
            .insert(note)
            .execute()
        
        print("✅ Note created successfully")
    }
    
    /// Update an existing note
    func updateNote(_ note: Note) async throws {
        print("✏️ Updating note: \(note.id)")
        
        let note = SupabaseNote(
            id: note.id,
            amount: note.amount,
            description: note.transactionDescription,
            date: note.date,
            category: note.category,
            thumbnail_url: note.thumbnailUrl
        )
        
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
    func fetchNote(id: String) async throws -> Note? {
        print("📥 Fetching note: \(id)")
        
        let response: [SupabaseNote] = try await client
            .from("notes")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        return response.first?.toNote()
    }
    
    // MARK: - 🔍 Search & Filter
    
    /// Search notes by description
    func searchNotes(query: String) async throws -> [Note] {
        print("🔍 Searching notes: \(query)")
        
        let response: [SupabaseNote] = try await client
            .from("notes")
            .select()
            .ilike("description", pattern: "%\(query)%")
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toNote() }
    }
    
    /// Filter notes by category
    func fetchNotesByCategory(category: String) async throws -> [Note] {
        print("📂 Fetching notes for category: \(category)")
        
        let response: [SupabaseNote] = try await client
            .from("notes")
            .select()
            .eq("category", value: category)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toNote() }
    }
    
    /// Filter notes by date range
    func fetchNotesByDateRange(from: Date, to: Date) async throws -> [Note] {
        print("📅 Fetching notes from \(from) to \(to)")
        
        let response: [SupabaseNote] = try await client
            .from("notes")
            .select()
            .gte("date", value: from.ISO8601Format())
            .lte("date", value: to.ISO8601Format())
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toNote() }
    }
    
    // MARK: - 📊 Statistics
    
    /// Calculate statistics from notes
    func fetchStatistics() async throws -> TransactionStatistics {
        let notes = try await fetchNotes()
        
        let totalIncome = notes.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let totalExpenses = notes.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        let balance = totalIncome - totalExpenses
        
        // This month
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let thisMonthNotes = notes.filter { $0.date >= startOfMonth }
        let monthlyTotal = thisMonthNotes.reduce(0) { $0 + $1.amount }
        
        return TransactionStatistics(
            totalTransactions: notes.count,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            balance: balance,
            monthlyTotal: monthlyTotal,
            averageTransaction: notes.isEmpty ? 0 : (totalIncome + totalExpenses) / Double(notes.count)
        )
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

// MARK: - 🗄️ Supabase Note Model

struct SupabaseNote: Codable {
    let id: String
    let amount: Double
    let description: String
    let date: Date
    let category: String
    let thumbnail_url: String?
    let created_at: Date?
    let updated_at: Date?
    
    init(
        id: String,
        amount: Double,
        description: String,
        date: Date,
        category: String,
        thumbnail_url: String?
    ) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.category = category
        self.thumbnail_url = thumbnail_url
        self.created_at = Date()
        self.updated_at = Date()
    }
    
    // Convert to Note model
    func toNote() -> Note {
        Note(
            id: id,
            amount: amount,
            description: description,
            date: date,
            category: category,
            thumbnailUrl: thumbnail_url,
            syncStatus: .synced
        )
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
