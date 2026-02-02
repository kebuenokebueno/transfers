//
//  EditTransactionView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI
import StoreKit

struct EditTransactionView: View {
    let transactionId: String
    @Environment(Router.self) private var router
    @Environment(AnalyticsService.self) private var analyticsService
    @State private var transaction: Transfer?
    @State private var amount = ""
    @State private var description = ""
    @State private var category = ""
    
    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                
                TextField("Description", text: $description)
                
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
            }
        }
        .navigationTitle("Edit Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    analyticsService.trackButtonTap("save_edited_transaction")
                    // TODO: Save changes
                    router.navigateBack()
                }
                .disabled(amount.isEmpty || description.isEmpty)
            }
        }
        .task {
            // TODO: Fetch transaction from service
            transaction = Transfer(
                id: transactionId,
                amount: -50.0,
                description: "Transaction \(transactionId)",
                date: Date(),
                category: "Food",
                thumbnailUrl: nil
            )
            
            if let transaction = transaction {
                amount = String(abs(transaction.amount))
                self.description = transaction.description
                category = transaction.category
            }
        }
        .onAppear {
            analyticsService.trackScreenView("edit_transaction")
        }
    }
}
