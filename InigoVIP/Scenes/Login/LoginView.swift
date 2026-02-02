//
//  Login.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    @Environment(AnalyticsService.self) private var analyticsService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "banknote.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding(.bottom, 20)
                    // ✅ VoiceOver: Decorative image
                    .accessibilityHidden(true)
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        // ✅ VoiceOver: Descriptive label
                        .accessibilityLabel("Email address")
                        .accessibilityHint("Enter your email address")
                        // ✅ VoiceControl: Named field
                        .accessibilityIdentifier("emailField")
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        // ✅ VoiceOver: Descriptive label
                        .accessibilityLabel("Password")
                        .accessibilityHint("Enter your password")
                        // ✅ VoiceControl: Named field
                        .accessibilityIdentifier("passwordField")
                }
                
                Button {
                    handleLogin()
                } label: {
                    if isLoggingIn {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Log In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .disabled(isLoggingIn)
                // ✅ VoiceOver: Clear action
                .accessibilityLabel(isLoggingIn ? "Logging in" : "Log in")
                .accessibilityHint("Double tap to log into your account")
                // ✅ VoiceControl: Named button
                .accessibilityIdentifier("loginButton")
                // ✅ AssistiveAccess: Minimum touch target
                .frame(minHeight: 44)
                
                Spacer()
            }
            .padding(.top, 60)
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
        }
        // ✅ Accessibility Nutrition Label: Scene information
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Login Screen")
    }
    
    private func handleLogin() {
        analyticsService.trackButtonTap("login")
        isLoggingIn = true
        
        Task {
            await authService.login(email: email, password: password)
            isLoggingIn = false
            
            // ✅ VoiceOver: Announce successful login
            UIAccessibility.post(notification: .announcement, argument: "Login successful")
        }
    }
}
