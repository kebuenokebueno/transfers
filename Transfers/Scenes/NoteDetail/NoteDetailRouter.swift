//
//  NoteDetailRouter.swift
//  Transfers
//

import Foundation

protocol NoteDetailRoutingLogic {
    func routeToEditNote(noteId: String)
    func dismiss()
}

@MainActor
class NoteDetailRouter: NoteDetailRoutingLogic {

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func routeToEditNote(noteId: String) {
        router.navigate(to: .editNote(id: noteId))
    }

    func dismiss() {
        router.navigateBack()
    }
}
