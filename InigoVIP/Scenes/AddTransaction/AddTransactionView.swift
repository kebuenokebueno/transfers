//
//  AddTransaction.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI
import UIKit
import StoreKit

struct AddTransactionView: View {
    @Environment(Router.self) private var router
    @Environment(AnalyticsService.self) private var analyticsService
    @State private var amount = ""
    @State private var description = ""
    @State private var category = "Food"
    @State private var isIncome = false
    
    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Transaction Type", selection: $isIncome) {
                        Text("Expense").tag(false)
                        Text("Income").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .accessibilityLabel("Transaction amount")
                    
                    TextField("Description", text: $description)
                        .accessibilityLabel("Transaction description")
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        analyticsService.trackButtonTap("cancel_add_transaction")
                        router.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        analyticsService.trackButtonTap("save_new_transaction")
                        // TODO: Save transaction logic here
                        router.dismiss()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
            .onAppear {
                analyticsService.trackScreenView("add_transaction")
            }
        }
    }
}
