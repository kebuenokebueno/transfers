//
//  NoteDetailView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService
    @Environment(\.modelContext) private var modelContext
    
    let noteId: String
    
    @Query private var notes: [Note]
    
    @State private var showDeleteConfirmation = false
    @State private var viewController: NoteListViewController?
    
    init(noteId: String) {
        self.noteId = noteId
        
        // Query only this specific note from SwiftData
        let predicate = #Predicate<Note> { note in
            note.id == noteId
        }
        _notes = Query(filter: predicate, sort: \Note.date, order: .reverse)
    }
    
    private var note: Note? {
        notes.first
    }
    
    // Formatted display data
    private var displayedNote: NoteScene.FetchNote.ViewModel.DisplayedNote? {
        guard let note = note else { return nil }
        
        return NoteScene.FetchNote.ViewModel.DisplayedNote(
            id: note.id,
            amount: note.formattedAmount,
            description: note.noteDescription,
            date: note.formattedDate,
            category: note.category,
            isPositive: note.isPositive,
            syncStatus: note.syncStatusEnum.rawValue.capitalized
        )
    }
    
    var body: some View {
        ScrollView {
            if let displayedNote = displayedNote, let note = note {
                VStack(spacing: 24) {
                    // Amount
                    Text(displayedNote.amount)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(displayedNote.isPositive ? .green : .primary)
                    
                    // Category
                    Text(displayedNote.category)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                    
                    Divider()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Description", value: displayedNote.description)
                        DetailRow(label: "Date", value: displayedNote.date)
                        DetailRow(label: "Sync Status", value: displayedNote.syncStatus)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Edit Button
                    Button {
                        router.navigate(to: .editNote(id: displayedNote.id))
                    } label: {
                        Label("Edit Note", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // Delete Button
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Note", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                // Note not found or was deleted
                ContentUnavailableView(
                    "Note Not Found",
                    systemImage: "note.text",
                    description: Text("This note may have been deleted")
                )
            }
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete Note", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteNote()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure? This cannot be undone.")
        }
        .task {
            if viewController == nil {
                setupVIP()
            }
        }
    }
    
    private func setupVIP() {
        let interactor = NoteListInteractor(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService
        )
        let presenter = NoteListPresenter()
        let vc = NoteListViewController()
        
        vc.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        
        viewController = vc
    }
    
    private func deleteNote() {
        guard let note = note else { return }
        
        Task {
            // Delete from SwiftData via modelContext (triggers @Query update)
            modelContext.delete(note)
            
            // Save immediately
            try? modelContext.save()
            
            // Dismiss immediately (note is gone from DB)
            dismiss()
            
            // Then delete from Supabase in background
            await noteWorker.deleteNote(id: note.id)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
