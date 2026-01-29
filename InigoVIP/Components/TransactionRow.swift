//
//  TransactionRow.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI


struct TransactionRow: View {
    let transaction: TransactionList.FetchTransactions.ViewModel.DisplayedTransaction
    
    // ✅ Assistive Access: Dynamic Type awareness
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        HStack(alignment: .top, spacing: dynamicTypeSize.isAccessibilitySize ? 16 : 12) {
            // Mostrar imagen de la API o icono por defecto
            if let thumbnailUrl = transaction.thumbnailUrl,
               let url = URL(string: thumbnailUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: dynamicTypeSize.isAccessibilitySize ? 52 : 44,
                                   height: dynamicTypeSize.isAccessibilitySize ? 52 : 44)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: dynamicTypeSize.isAccessibilitySize ? 52 : 44,
                                   height: dynamicTypeSize.isAccessibilitySize ? 52 : 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        CategoryIcon(category: transaction.category)
                    @unknown default:
                        CategoryIcon(category: transaction.category)
                    }
                }
                // ✅ VoiceOver: Decorative images should be hidden
                .accessibilityHidden(true)
            } else {
                CategoryIcon(category: transaction.category)
                    // ✅ VoiceOver: Decorative images should be hidden
                    .accessibilityHidden(true)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                    // ✅ Dynamic Type: Scale with user preferences
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                
                Text(transaction.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(transaction.category)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
            
            Spacer(minLength: 8)
            
            Text(transaction.amount)
                .font(.headline)
                .foregroundStyle(transaction.isPositive ? .green : .primary)
                // ✅ Dynamic Type: Ensure readability
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 8 : 4)
        // ✅ Assistive Access: Minimum touch target 44x44
        .frame(minHeight: 44)
    }
}
