//
//  RouterView.swift
//  Transfers
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

struct RouterView {
    @ViewBuilder
    static func destination(for route: Route) -> some View {
        switch route {
        case .noteDetail(let id):
            NoteDetailView(noteId: id)

        case .addNote:
            AddNoteView()
            
        case .editNote(let id):
            EditNoteView(noteId: id)
        }
    }
}
