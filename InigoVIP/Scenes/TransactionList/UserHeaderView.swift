//
//  UserHeaderView.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import Foundation
import SwiftUI

struct UserHeaderView: View {
    @Environment(AuthService.self) private var authService
    
    var body: some View {
        if authService.isLoggedIn, let user = authService.currentUser {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(user.name)
                        .font(.headline)
                }
                Spacer()
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .foregroundColor(.white)
                            .font(.headline)
                    )
                    // ✅ VoiceOver: Profile image description
                    .accessibilityLabel("Profile picture, \(user.name)")
            }
            .padding()
            .background(Color(.systemGray6))
            // ✅ VoiceOver: Combine elements into one announcement
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Welcome back, \(user.name)")
            // ✅ AssistiveAccess: Minimum touch target
            .frame(minHeight: 44)
        }
    }
}
