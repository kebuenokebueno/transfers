//
//  NoteDetailModels.swift
//  InigoVIP
//

import Foundation

enum NoteDetailScene {

    enum FetchNote {
        struct Request {
            let noteId: String
        }
        struct Response {
            let note: NoteEntity?
        }
        struct ViewModel {
            let note: NoteViewModel?
        }
    }

    enum DeleteNote {
        struct Request {
            let noteId: String
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
