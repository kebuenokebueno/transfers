//
//  NoteListRouter.swift
//  InigoVIP
//

import Foundation

protocol NoteListRoutingLogic {
    func routeToNoteDetail(noteId: String)
    func routeToAddNote()
    func routeToEditNote(noteId: String)
}

@MainActor
class NoteListRouter: NoteListRoutingLogic {
    weak var viewController: NoteListViewController?

    private let router: Router                        // NavigationPath router

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
