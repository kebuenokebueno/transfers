//
//  CategoryPicker.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//


import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: String
    
    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
    
    var body: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(categories, id: \.self) { category in
                Text(category).tag(category)
                    // ✅ VoiceOver: Each option is clearly labeled
                    .accessibilityLabel("\(category) category")
            }
        }
        // ✅ VoiceOver: Describe picker purpose
        .accessibilityLabel("Transaction category")
        .accessibilityValue(selectedCategory)
        .accessibilityHint("Select a category for this transaction")
        // ✅ VoiceControl: Named picker
        .accessibilityIdentifier("categoryPicker")
        // ✅ Assistive Access: Wheel picker is easier than menu
        .pickerStyle(.wheel)
    }
}
