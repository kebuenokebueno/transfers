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
        // Reload when AddNote sheet is dismissed
        .task(id: router.presentedSheet == nil) {
            guard viewController.interactor != nil else { return }
            viewController.loadNotes()
        }
        // Reload when navigating back from EditNote or NoteDetail
        .task(id: router.path.count) {
            guard viewController.interactor != nil else { return }
            viewController.loadNotes()
        }
        .task { setup() }
    }

    // MARK: - VIP Assembly

    private func setup() {
        guard viewController.interactor == nil else { return }

        let interactor = NoteListInteractor(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService
        )
        let presenter  = NoteListPresenter()
        let noteRouter = NoteListRouter(router: router)

        viewController.interactor    = interactor
        viewController.router        = noteRouter
        interactor.presenter         = presenter
        presenter.viewController     = viewController
        noteRouter.viewController    = viewController

        viewController.loadNotes()
    }
}
