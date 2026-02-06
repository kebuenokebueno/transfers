//
//  EditNoteView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI
import SwiftData

struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService
    
    @State private var viewController: NoteListViewController?
    
    let noteId: String
    
    @Query private var notes: [NoteEntity]
    
    @State private var amount = ""
    @State private var description = ""
    @State private var category = ""
    @State private var isLoading = true
    @State private var isSaving = false
    
    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
    
    init(noteId: String) {
        self.noteId = noteId
        
        // Query only this specific note from SwiftData
        let predicate = #Predicate<NoteEntity> { note in
            note.id == noteId
        }
        _notes = Query(filter: predicate)
    }
    
    private var note: NoteEntity? {
        notes.first
    }
    
    var body: some View {
        Form {
            if isLoading {
                ProgressView("Loading...")
            } else if note != nil {
                Section("Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Note Not Found",
                    systemImage: "note.text",
                    description: Text("This note may have been deleted")
                )
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(amount.isEmpty || description.isEmpty || isSaving)
            }
        }
        .disabled(isSaving)
        .overlay {
            if isSaving {
                ProgressView("Saving...")
            }
        }
        .alert("Success", isPresented: .constant(viewController?.successMessage != nil)) {
            Button("OK") {
                viewController?.successMessage = nil
                dismiss()
            }
        } message: {
            if let message = viewController?.successMessage {
                Text(message)
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
            if viewController == nil {
                setupVIP()
            }
            loadNote()
        }
        .onChange(of: note) { oldValue, newValue in
            if let newValue = newValue, !isSaving {
                amount = String(abs(newValue.amount))
                description = newValue.noteDescription
                category = newValue.category
            }
        }
    }
    
    private func setupVIP() {
        // ✅ Pass both noteWorker AND swiftDataService
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
    
    private func loadNote() {
        // Load data from SwiftData note
        if let note = note {
            amount = String(abs(note.amount))
            description = note.noteDescription
            category = note.category
        }
        isLoading = false
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount),
              let note = note else { return }
        
        isSaving = true
        
        Task {
            // Create updated note with same ID
            let updatedNote = NoteEntity(
                id: note.id,
                amount: note.isPositive ? amountValue : -amountValue,
                description: description,
                date: note.date,
                category: category,
                syncStatus: .pending
            )
            
            // Update through worker
            await noteWorker.updateNote(updatedNote)
            
            isSaving = false
            
            // Dismiss after short delay to show update
            try? await Task.sleep(for: .milliseconds(500))
            dismiss()
        }
    }
}
