//
//  NoteDetailView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import SwiftUI



struct NoteDetailView: View {
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var viewController: NoteListViewController?
    
    let noteId: String
    private let noteManager: NoteManager
    
    @State private var displayedNote: NoteScene.FetchNote.ViewModel.DisplayedNote?
    @State private var showDeleteConfirmation = false
    
    init(noteId: String) {
        self.noteId = noteId
        self.noteManager = noteManager
    }
    
    var body: some View {
        ScrollView {
            if let note = displayedNote {
                VStack(spacing: 24) {
                    // Amount
                    Text(note.amount)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(note.isPositive ? .green : .primary)
                    
                    // Category
                    Text(note.category)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                    
                    Divider()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Description", value: note.description)
                        DetailRow(label: "Date", value: note.date)
                        DetailRow(label: "Sync Status", value: note.syncStatus)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Edit Button
                    Button {
                        router.navigate(to: .editNote(id: note.id))
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
                ProgressView("Loading...")
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
                loadNote()
            }
        }
    }
    
    private func setupVIP() {
        let interactor = NoteListInteractor(noteManager: noteManager)
        let presenter = NoteListPresenter()
        let vc = NoteListViewController()
        
        vc.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        
        viewController = vc
    }
    
    private func loadNote() {
        Task {
            await viewController?.interactor?.fetchNote(
                request: NoteScene.FetchNote.Request(noteId: noteId)
            )
            
            // Get displayed note from note manager
            if let note = noteManager.notes.first(where: { $0.id == noteId }) {
                displayedNote = NoteScene.FetchNote.ViewModel.DisplayedNote(
                    id: note.id,
                    amount: note.formattedAmount,
                    description: note.noteDescription,
                    date: note.formattedDate,
                    category: note.category,
                    isPositive: note.isPositive,
                    syncStatus: note.syncStatusEnum.rawValue.capitalized
                )
            }
        }
    }
    
    private func deleteNote() {
        viewController?.deleteNote(noteId: noteId)
        dismiss()
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
