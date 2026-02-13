import Foundation

protocol NoteListDisplayLogic: AnyObject {
    func displayNotes(viewModel: NoteScene.FetchNotes.ViewModel)
    func displayDeleteResult(viewModel: NoteScene.DeleteNote.ViewModel)
}

@MainActor
@Observable
class NoteListViewController: NoteListDisplayLogic {
    var interactor: NoteListBusinessLogic?
    var router: NoteListRoutingLogic?

    // View State
    var displayedNotes: [NoteViewModel] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displayNotes(viewModel: NoteScene.FetchNotes.ViewModel) {
        displayedNotes = viewModel.displayedNotes
        isLoading = false
    }

    func displayDeleteResult(viewModel: NoteScene.DeleteNote.ViewModel) {
        if !viewModel.success { errorMessage = viewModel.message }
    }

    // MARK: - User Actions → Interactor (business logic)

    func loadNotes() {
        isLoading = true
        Task { await interactor?.fetchNotes() }
    }

    func deleteNote(noteId: String) {
        Task {
            await interactor?.deleteNote(request: .init(noteId: noteId))
        }
    }

    // MARK: - User Actions → Router (navigation)

    func didSelectNote(noteId: String) {
        router?.routeToNoteDetail(noteId: noteId)
    }

    func didTapAddNote() {
        router?.routeToAddNote()
    }

    func didTapEditNote(noteId: String) {
        router?.routeToEditNote(noteId: noteId)
    }
}
