//
//  AmountEditor.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI


// MARK: - Reusable Components with @Binding
struct AmountEditor: View {
    @Binding var amount: String
    
    // ✅ Assistive Access: Input validation feedback
    @State private var isValidAmount = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Amount")
                Spacer()
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    // ✅ VoiceOver: Descriptive label and value
                    .accessibilityLabel("Transaction amount")
                    .accessibilityValue(amount.isEmpty ? "No amount entered" : amount)
                    .accessibilityHint("Enter the transaction amount in euros")
                    // ✅ VoiceControl: Named field
                    .accessibilityIdentifier("amountField")
                    .onChange(of: amount) { _, newValue in
                        validateAmount(newValue)
                    }
            }
            
            if !isValidAmount {
                Text("Please enter a valid amount")
                    .font(.caption)
                    .foregroundStyle(.red)
                    // ✅ VoiceOver: Announce validation errors
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        // ✅ Assistive Access: Minimum touch target
        .frame(minHeight: 44)
    }
    
    private func validateAmount(_ value: String) {
        // Simple validation example
        isValidAmount = !value.isEmpty && Double(value.replacingOccurrences(of: "€", with: "").trimmingCharacters(in: .whitespaces)) != nil
    }
}
