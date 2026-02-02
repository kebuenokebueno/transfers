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
            TransactionDetailView(transactionId: id)
            
        case .settings:
            SettingsView()
            
        case .profile:
            ProfileView()
            
        case .addTransaction:
            AddTransactionView()
            
        case .editTransaction(let id):
            EditTransactionView(transactionId: id)
        }
    }
}
