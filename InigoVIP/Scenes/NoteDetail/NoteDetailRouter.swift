//
//  NoteDetailRouter.swift
//  InigoVIP
//

import Foundation

protocol NoteDetailRoutingLogic {
    func routeToEditNote(noteId: String)
    func dismiss()
}

@MainActor
class NoteDetailRouter: NoteDetailRoutingLogic {
    weak var viewController: NoteDetailViewController?
    weak var dataStore: NoteDetailDataStore?

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func routeToEditNote(noteId: String) {
        dataStore?.noteId = noteId
        router.navigate(to: .editNote(id: noteId))
    }

    func dismiss() {
        router.navigateBack()
    }
}
