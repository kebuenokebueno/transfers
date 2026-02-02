//
//  NoteListView.swift
//  InigoVIP
//
//  Created by Inigo on 27/1/26.
//

import SwiftUI

struct NoteListView: View {
    @Environment(Router.self) private var router
    @Environment(NoteWorker.self) private var noteWorker
    @State private var viewController: NoteListViewController?

    
    var body: some View {
        Group {
            if let vc = viewController {
                NoteListContentView(viewController: vc, router: router)
            } else {
                ProgressView("Initializing...")
            }
        }
        .task {
            if viewController == nil {
                setupVIP()
                viewController?.loadNotes()
            }
        }
    }
    
    private func setupVIP() {
        // Create VIP components
        let interactor = NoteListInteractor(noteWorker: noteWorker)
        let presenter = NoteListPresenter()
        let vc = NoteListViewController()
        
        // Wire them together
        vc.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        
        viewController = vc
    }
}
