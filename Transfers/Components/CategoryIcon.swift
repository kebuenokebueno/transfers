//
//  CategoryIcon.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI

struct CategoryIcon: View {
    let category: String
    
    var iconName: String {
        switch category {
        case "Food": return "fork.knife"
        case "Utilities": return "bolt.fill"
        case "Income": return "dollarsign.circle.fill"
        case "Transport": return "car.fill"
        case "Entertainment": return "tv.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    // ✅ Dynamic Type: Scale icon appropriately
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var iconSize: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 52 : 44
    }
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundStyle(.white)
            .frame(width: iconSize, height: iconSize)
            .background(Color.blue)
            .clipShape(Circle())
            // ✅ VoiceOver: Meaningful label instead of icon name
            .accessibilityLabel("\(category) category icon")
    }
}
