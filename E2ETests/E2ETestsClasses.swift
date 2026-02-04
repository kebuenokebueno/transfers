//
//  E2ETestsClasses.swift
//  InigoVIP
//
//  Created by Inigo on 4/2/26.
//

import Foundation
import Supabase
@testable import InigoVIP


@MainActor
class TestSupabaseService {
    private let client: SupabaseClient
    private let tableName: String
    
    init(tableName: String = "notes_test") {
        self.tableName = tableName
        self.client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseTestURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonTestKey
        )
    }
    
    // MARK: - CRUD (igual que SupabaseService pero con tabla de test)
    
    func fetchNotes() async throws -> [Note] {
        let response: [Note] = try await client
            .from(tableName)
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }
    
    func createNote(_ note: Note) async throws {
        try await client
            .from(tableName)
            .insert(note)
            .execute()
    }
    
    func updateNote(_ note: Note) async throws {
        try await client
            .from(tableName)
            .update(note)
            .eq("id", value: note.id)
            .execute()
    }
    
    func deleteNote(id: String) async throws {
        try await client
            .from(tableName)
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Test Helpers
    
    /// Limpia todos los datos de test
    func cleanupAllTestData() async throws {
        try await client
            .from(tableName)
            .delete()
            .neq("id", value: "")  // Borra todo
            .execute()
    }
    
    /// Verifica conexión
    func testConnection() async -> Bool {
        do {
            _ = try await fetchNotes()
            return true
        } catch {
            print("❌ E2E: Supabase connection failed: \(error)")
            return false
        }
    }
}
