//
//  NoteListView.swift
//  Transfers
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    @State private var viewModel: NoteListViewModel?

    var body: some View {
        Group {
            if let viewModel {
                NoteListContent(
                    notes: viewModel.displayedNotes,
                    isLoading: viewModel.isLoading,
                    lastError: viewModel.errorMessage,
                    onTapNote: { note in
                        viewModel.didSelectNote(noteId: note.id)
                    },
                    onDeleteNote: { note in
                        viewModel.deleteNote(noteId: note.id)
                    },
                    onAddNote: {
                        viewModel.didTapAddNote()
                    },
                    onFetch: {
                        viewModel.loadNotes()
                    },
                    onClearError: {
                        viewModel.errorMessage = nil
                    }
                )
                // Reload when AddNote sheet is dismissed
                .task(id: router.presentedSheet == nil) {
                    viewModel.loadNotes()
                }
                // Reload when navigating back from EditNote or NoteDetail
                .task(id: router.path.count) {
                    viewModel.loadNotes()
                }
            } else {
                ProgressView()
                    .task { setup() }
            }
        }
    }

    // MARK: - Setup

    private func setup() {
        guard viewModel == nil else { return }
        
        viewModel = NoteListViewModel(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService,
            router: router
        )
        viewModel?.loadNotes()
    }
}
