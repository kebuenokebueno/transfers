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
        case .transferDetail(let id):
            TransferDetailView(transferId: id)

        case .addTransfer:
            AddTransferView()
            
        case .editTransfer(let id):
            EditTransferView(transferId: id)
        }
    }
}
