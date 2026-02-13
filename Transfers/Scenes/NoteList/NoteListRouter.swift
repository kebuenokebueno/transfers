//
//  NoteListRouter.swift
//  Transfers
//

import Foundation

protocol NoteListRoutingLogic {
    func routeToNoteDetail(noteId: String)
    func routeToAddNote()
    func routeToEditNote(noteId: String)
}

@MainActor
class NoteListRouter: NoteListRoutingLogic {

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    // MARK: - Navigation + Data Transfer

    func routeToNoteDetail(noteId: String) {
        router.navigate(to: .noteDetail(id: noteId))
    }

    func routeToAddNote() {
        router.present(sheet: .addNote)
    }

    func routeToEditNote(noteId: String) {
        router.navigate(to: .editNote(id: noteId))
    }
}
