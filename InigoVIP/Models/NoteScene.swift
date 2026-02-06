//
//  NoteScene.swift
//  InigoVIP
//
//  Created by Inigo on 3/2/26.
//

import Foundation

struct NoteViewModel: Identifiable {
    let id: String
    let amount: String
    let description: String
    let date: String
    let category: String
    let isPositive: Bool
    let syncStatus: String
}

enum NoteScene {
    
    // MARK: - Fetch Notes
    enum FetchNotes {
        
        struct Response {
            let notes: [NoteEntity]
        }
        
        struct ViewModel {
            let displayedNotes: [NoteViewModel]
        }
    }

    // MARK: - Create Note
    enum CreateNote {
        struct Request {
            let amount: Double
            let description: String
            let category: String
            let isIncome: Bool
        }
        
        struct Response {
            let note: NoteEntity
            let success: Bool
        }
        
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
    
    // MARK: - Update Note
    enum UpdateNote {
        struct Request {
            let noteId: String
            let amount: Double
            let description: String
            let category: String
        }
        
        struct Response {
            let note: NoteEntity
            let success: Bool
        }
        
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
    
    // MARK: - Delete Note
    enum DeleteNote {
        struct Request {
            let noteId: String
        }
        
        struct Response {
            let success: Bool
            let noteId: String
        }
        
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
    
    // MARK: - Fetch Single Note
    enum FetchNote {
        struct Request {
            let noteId: String
        }
        
        struct Response {
            let note: NoteEntity?
        }
        
        struct ViewModel {
            let displayedNote: NoteViewModel?
        }
    }
}
