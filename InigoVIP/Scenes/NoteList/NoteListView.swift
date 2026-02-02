//
//  NoteListView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Note.date, order: .reverse) private var notes: [Note]
    
    var body: some View {
        List {
            ForEach(notes) { note in
                NoteRow(note: note)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.navigate(to: .noteDetail(id: note.id))
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteNote(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: deleteNotes)
        }
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.present(sheet: .addNote)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if noteWorker.isLoading {
                ProgressView("Loading...")
            } else if notes.isEmpty {
                ContentUnavailableView(
                    "No Notes",
                    systemImage: "note.text",
                    description: Text("Tap + to add your first note")
                )
            }
        }
        .alert("Error", isPresented: .constant(noteWorker.lastError != nil)) {
            Button("OK") {
                noteWorker.lastError = nil
            }
        } message: {
            if let error = noteWorker.lastError {
                Text(error)
            }
        }
        .task {
            // Fetch notes on first load (syncs from cloud)
            await noteWorker.fetchNotes()
        }
        .refreshable {
            await noteWorker.fetchNotes()
        }
    }
    
    private func deleteNote(_ note: Note) {
        Task {
            // Delete from SwiftData via modelContext (triggers @Query update)
            modelContext.delete(note)
            
            // Save immediately
            try? modelContext.save()
            
            // Then delete from Supabase in background
            await noteWorker.deleteNote(id: note.id)
        }
    }
    
    // Native SwiftUI delete
    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            deleteNote(note)
        }
    }
}
