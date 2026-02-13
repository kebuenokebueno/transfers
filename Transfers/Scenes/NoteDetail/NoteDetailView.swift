//
//  NoteDetailView.swift
//  Transfers
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    let noteId: String

    @State private var viewModel: NoteDetailViewModel?
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            if let note = viewModel?.note {
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
                        viewModel?.didTapEdit(noteId: note.id)
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
            guard viewModel != nil else { return }
            viewModel?.loadNote(noteId: noteId)
        }
        .confirmationDialog("Delete Note", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel?.deleteNote(noteId: noteId)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure? This cannot be undone.")
        }
        .alert("Error", isPresented: .constant(viewModel?.errorMessage != nil)) {
            Button("OK") { viewModel?.errorMessage = nil }
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .task { setup() }
    }

    private func setup() {
        guard viewModel == nil else { return }
        
        viewModel = NoteDetailViewModel(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService,
            router: router
        )
        viewModel?.loadNote(noteId: noteId)
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
