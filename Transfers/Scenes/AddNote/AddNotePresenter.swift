//
//  AddNotePresenter.swift
//  InigoVIP
//

import Foundation

protocol AddNotePresentationLogic {
    func presentSaveResult(response: AddNoteScene.SaveNote.Response)
}

@MainActor
class AddNotePresenter: AddNotePresentationLogic {
    weak var viewController: AddNoteDisplayLogic?

    func presentSaveResult(response: AddNoteScene.SaveNote.Response) {
        let vm = AddNoteScene.SaveNote.ViewModel(
            success: response.success,
            message: response.success ? "Note created successfully" : "Failed to create note"
        )
        viewController?.displaySaveResult(viewModel: vm)
    }
}
