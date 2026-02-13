//
//  Route.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

enum Route: Hashable, Equatable {
    case noteDetail(id: String)
    case addNote
    case editNote(id: String)
}

extension Route: Identifiable {
    var id: String {
        switch self {
        case .noteDetail(let id):
            return "noteDetail_\(id)"
        case .addNote:
            return "addNote"
        case .editNote(let id):
            return "editNote_\(id)"
        }
    }
}
