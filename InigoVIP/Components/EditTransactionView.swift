//
//  EditTransactionView.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI


struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                        // ✅ In real VIP, this would trigger ViewController action
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // ✅ In real VIP, this would go through:
                        // View -> ViewController -> Interactor -> Worker
                        // Worker would use AnalyticsService internally
                        dismiss()
                    }
                }
            }
        }
    }
}
