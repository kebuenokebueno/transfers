//
//  EditNoteView.swift
//  Transfers
//

import SwiftUI

struct EditNoteView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    let noteId: String

    @State private var viewModel: EditNoteViewModel?

    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]

    var body: some View {
        Form {
            if let viewModel, !viewModel.isLoading {
                Section("Details") {
                    TextField("Amount", text: Binding(
                        get: { viewModel.amount },
                        set: { viewModel.amount = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    
                    TextField("Description", text: Binding(
                        get: { viewModel.description },
                        set: { viewModel.description = $0 }
                    ))
                    
                    Picker("Category", selection: Binding(
                        get: { viewModel.category },
                        set: { viewModel.category = $0 }
                    )) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel?.saveNote(noteId: noteId)
                }
                .disabled(
                    (viewModel?.amount.isEmpty ?? true) ||
                    (viewModel?.description.isEmpty ?? true) ||
                    (viewModel?.isSaving ?? false)
                )
            }
        }
        .disabled(viewModel?.isSaving ?? false)
        .overlay { if viewModel?.isSaving ?? false { ProgressView("Saving...") } }
        .alert("Error", isPresented: .constant(viewModel?.errorMessage != nil)) {
            Button("OK") { viewModel?.errorMessage = nil }
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .task { setup() }
    }

    private func setup() {
        guard viewModel == nil else { return }
        
        viewModel = EditNoteViewModel(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService,
            router: router
        )
        viewModel?.loadNote(noteId: noteId)
    }
}
