// NoteListView.swift

import SwiftUI
import SwiftData

// MARK: - Vista principal (con dependencias)
struct NoteListView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoteEntity.date, order: .reverse) private var notes: [NoteEntity]
    
    var body: some View {
        NoteListContent(
            notes: notes,
            isLoading: noteWorker.isLoading,
            lastError: noteWorker.lastError,
            onTapNote: { note in
                router.navigate(to: .noteDetail(id: note.id))
            },
            onDeleteNote: { note in
                deleteNote(note)
            },
            onAddNote: {
                router.present(sheet: .addNote)
            },
            onFetch: {
                await noteWorker.fetchNotes()
            },
            onClearError: {
                noteWorker.lastError = nil
            }
        )
    }
    
    private func deleteNote(_ note: NoteEntity) {
        Task {
            modelContext.delete(note)
            try? modelContext.save()
            await noteWorker.deleteNote(id: note.id)
        }
    }
}


