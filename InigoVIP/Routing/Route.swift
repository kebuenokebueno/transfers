//
//  Route.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

enum Route: Hashable, Equatable {
    case transactionDetail(id: String)
    case settings
//    case profile
    case addTransaction
    case editTransaction(id: String)
}


extension Route: Identifiable {
    var id: String {
        switch self {
        case .transactionDetail(let id):
            return "transactionDetail_\(id)"
        case .settings:
            return "settings"
//        case .profile:
//            return "profile"
        case .addTransaction:
            return "addTransaction"
        case .editTransaction(let id):
            return "editTransaction_\(id)"
        }
    }
}
