//
//  NoteListView.swift
//  InigoVIP
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService

    @State private var viewController = NoteListViewController()

    var body: some View {
        NoteListContent(
            notes: viewController.displayedNotes,
            isLoading: viewController.isLoading,
            lastError: viewController.errorMessage,
            onTapNote: { note in
                viewController.didSelectNote(noteId: note.id)
            },
            onDeleteNote: { note in
                viewController.deleteNote(noteId: note.id)
            },
            onAddNote: {
                viewController.didTapAddNote()
            },
            onFetch: {
                viewController.loadNotes()
            },
            onClearError: {
                viewController.errorMessage = nil
            }
        )
        .task { setup() }
    }

    // MARK: - VIP Assembly

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = NoteListInteractor(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService
        )
        let presenter = NoteListPresenter()
        let noteRouter = NoteListRouter(router: router)

        // Wire VIP cycle
        viewController.interactor = interactor
        viewController.router = noteRouter
        interactor.presenter = presenter
        presenter.viewController = viewController

        // Wire Router ↔ DataStore
        noteRouter.viewController = viewController
        noteRouter.dataStore = interactor

        viewController.loadNotes()
    }
}
