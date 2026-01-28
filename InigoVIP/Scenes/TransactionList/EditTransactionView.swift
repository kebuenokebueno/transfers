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
    
    // ✅ Assistive Access: Focus management
    @AccessibilityFocusState private var isAmountFieldFocused: Bool
    
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
                        // ✅ VoiceOver: Read-only field context
                        .accessibilityLabel("Description: \(description)")
                        .accessibilityAddTraits(.isStaticText)
                    
                    AmountEditor(amount: $editedAmount)
                        // ✅ Assistive Access: Set initial focus
                        .accessibilityFocused($isAmountFieldFocused)
                    
                    CategoryPicker(selectedCategory: $editedCategory)
                }
                // ✅ VoiceOver: Group related fields
                .accessibilityElement(children: .contain)
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    // ✅ VoiceOver: Clear action
                    .accessibilityLabel("Cancel editing")
                    .accessibilityHint("Discards changes and closes the editor")
                    // ✅ VoiceControl: Named button
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // ✅ VoiceOver: Announce save completion
                        UIAccessibility.post(notification: .announcement, argument: "Transaction saved")
                        dismiss()
                    }
                    // ✅ VoiceOver: Clear action
                    .accessibilityLabel("Save transaction")
                    .accessibilityHint("Saves your changes and closes the editor")
                    // ✅ VoiceControl: Named button
                    .accessibilityIdentifier("saveButton")
                }
            }
            // ✅ Assistive Access: Set focus when view appears
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAmountFieldFocused = true
                }
            }
        }
        // ✅ Accessibility Nutrition Label: Modal context
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Edit Transaction Screen")
    }
}
