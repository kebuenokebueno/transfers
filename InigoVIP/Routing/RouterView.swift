//
//  RouterView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

struct RouterView {
    @ViewBuilder
    static func destination(for route: Route) -> some View {
        switch route {
        case .transactionDetail(let id):
            NoteDetailView(noteId: id)
            
        case .settings:
            SettingsView()
            
//        case .profile:
//            ProfileView()
            
        case .addTransaction:
            AddNoteView()
            
        case .editTransaction(let id):
            EditNoteView(noteId: id)
        }
    }
}
