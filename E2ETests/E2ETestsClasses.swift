//
//  E2ETestsClasses.swift
//  TransfersTests
//

import Foundation
import Supabase
@testable import Transfers

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

    // MARK: - CRUD

    func fetchNotes() async throws -> [NoteEntity] {
        let response: [NoteEntity] = try await client
            .from(tableName)
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }

    func createNote(_ note: NoteEntity) async throws {
        try await client
            .from(tableName)
            .insert(note)
            .execute()
    }

    func updateNote(_ note: NoteEntity) async throws {
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

    func cleanupAllTestData() async throws {
        try await client
            .from(tableName)
            .delete()
            .neq("id", value: "")
            .execute()
    }

    func testConnection() async -> Bool {
        do {
            _ = try await fetchNotes()
            return true
        } catch {
            print("E2E: Supabase connection failed: \(error)")
            return false
        }
    }
}
