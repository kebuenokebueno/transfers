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

    @State private var viewController = EditNoteViewController()

    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]

    var body: some View {
        Form {
            if viewController.isLoading {
                ProgressView("Loading...")
            } else {
                Section("Details") {
                    TextField("Amount", text: $viewController.amount)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $viewController.description)
                    Picker("Category", selection: $viewController.category) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewController.saveNote(noteId: noteId)
                }
                .disabled(
                    viewController.amount.isEmpty ||
                    viewController.description.isEmpty ||
                    viewController.isSaving
                )
            }
        }
        .disabled(viewController.isSaving)
        .overlay { if viewController.isSaving { ProgressView("Saving...") } }
        .alert("Error", isPresented: .constant(viewController.errorMessage != nil)) {
            Button("OK") { viewController.errorMessage = nil }
        } message: {
            Text(viewController.errorMessage ?? "")
        }
        .task { setup() }
    }

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = EditNoteInteractor(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService
        )
        let presenter  = EditNotePresenter()
        let noteRouter = EditNoteRouter(router: router)

        viewController.interactor = interactor
        viewController.router = noteRouter
        interactor.presenter = presenter
        presenter.viewController = viewController

        viewController.loadNote(noteId: noteId)
    }
}
