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
        case .noteDetail(let id):
            TransferDetailView(transferId: id)

        case .addNote:
            AddTransferView()
            
        case .editNote(let id):
            EditTransferView(transferId: id)
        }
    }
}
