//
//  EditNoteModels.swift
//  InigoVIP
//

import Foundation

enum EditNoteScene {

    enum LoadNote {
        struct Request {
            let noteId: String
        }
        struct Response {
            let note: NoteEntity?
        }
        struct ViewModel {
            let note: NoteViewModel?
            let amount: String
            let description: String
            let category: String
        }
    }

    enum SaveNote {
        struct Request {
            let noteId: String
            let amount: Double
            let description: String
            let category: String
            let isPositive: Bool
        }
        struct Response {
            let success: Bool
        }
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
}
