//
//  Route.swift
//  Transfers
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

enum Route: Hashable, Equatable {
    case transferDetail(id: String)
    case addTransfer
    case editTransfer(id: String)
}

extension Route: Identifiable {
    var id: String {
        switch self {
        case .transferDetail(let id):
            return "transferDetail_\(id)"
        case .addTransfer:
            return "addTransfer"
        case .editTransfer(let id):
            return "editTransfer_\(id)"
        }
    }
}
