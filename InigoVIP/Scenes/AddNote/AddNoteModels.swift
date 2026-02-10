//
//  AddNoteModels.swift
//  InigoVIP
//

import Foundation

enum AddNoteScene {

    enum SaveNote {
        struct Request {
            let amount: Double
            let description: String
            let category: String
            let isIncome: Bool
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
