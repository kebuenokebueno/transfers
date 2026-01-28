//
//  EditTransactionView.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI



struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AnalyticsService.self) private var analyticsService
    
    let description: String
    let amount: String
    let category: String
    
    @State private var editedAmount: String
    @State private var editedCategory: String
    
    init(description: String, amount: String, category: String) {
        self.description = description
        self.amount = amount
        self.category = category
        _editedAmount = State(initialValue: amount)
        _editedCategory = State(initialValue: category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    LabeledContent("Description", value: description)
                    AmountEditor(amount: $editedAmount)
                    CategoryPicker(selectedCategory: $editedCategory)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        analyticsService.trackButtonTap("edit_cancel")
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        analyticsService.trackButtonTap("edit_save")
                        // In real app, would update through VIP
                        dismiss()
                    }
                }
            }
        }
    }
}
