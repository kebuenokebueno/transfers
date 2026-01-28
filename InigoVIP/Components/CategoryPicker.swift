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
            }
        }
    }
}
