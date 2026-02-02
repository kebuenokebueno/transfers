//
//  EditNoteView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI
import StoreKit

struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewController: NoteListViewController?
    @Environment(NoteWorker.self) private var noteWorker  // ← Get from environment

    let noteId: String
    
    @State private var amount = ""
    @State private var description = ""
    @State private var category = ""
    @State private var isLoading = true
    
    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
    
    init(noteId: String) {
        self.noteId = noteId
    }
    
    var body: some View {
        Form {
            if isLoading {
                ProgressView("Loading...")
            } else {
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
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(amount.isEmpty || description.isEmpty)
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
        .task {
            if viewController == nil {
                setupVIP()
                loadNote()
            }
        }
    }
    
    private func setupVIP() {
        let interactor = NoteListInteractor(noteWorker: noteWorker)
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
            
            // Load data from note manager
            if let note = noteWorker.notes.first(where: { $0.id == noteId }) {
                amount = String(abs(note.amount))
                description = note.noteDescription
                category = note.category
            }
            
            isLoading = false
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        viewController?.updateNote(
            noteId: noteId,
            amount: amountValue,
            description: description,
            category: category
        )
    }
}
