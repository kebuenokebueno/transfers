//
//  NoteDetailView.swift
//  InigoVIP
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    let noteId: String

    @State private var viewController = NoteDetailViewController()
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            if let note = viewController.note {
                VStack(spacing: 24) {
                    Text(note.amount)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(note.isPositive ? .green : .primary)

                    Text(note.category)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(20)

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Description", value: note.description)
                        DetailRow(label: "Date",        value: note.date)
                        DetailRow(label: "Sync Status", value: note.syncStatus)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Spacer()

                    Button {
                        viewController.didTapEdit(noteId: note.id)
                    } label: {
                        Label("Edit Note", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)

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
                ContentUnavailableView(
                    "Note Not Found",
                    systemImage: "note.text",
                    description: Text("This note may have been deleted")
                )
            }
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        // Reload when navigating back from EditNote
        .task(id: router.path.count) {
            guard viewController.interactor != nil else { return }
            viewController.loadNote(noteId: noteId)
        }
        .confirmationDialog("Delete Note", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewController.deleteNote(noteId: noteId)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure? This cannot be undone.")
        }
        .alert("Error", isPresented: .constant(viewController.errorMessage != nil)) {
            Button("OK") { viewController.errorMessage = nil }
        } message: {
            Text(viewController.errorMessage ?? "")
        }
        .task { setup() }
    }

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = NoteDetailInteractor(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService
        )
        let presenter  = NoteDetailPresenter()
        let noteRouter = NoteDetailRouter(router: router)

        viewController.interactor    = interactor
        viewController.router        = noteRouter
        interactor.presenter         = presenter
        presenter.viewController     = viewController

        viewController.loadNote(noteId: noteId)
    }
}

// MARK: - Supporting Views

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
