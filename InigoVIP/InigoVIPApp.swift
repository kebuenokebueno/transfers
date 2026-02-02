// MARK: - InigoVIP App Entry Point
// File: InigoVIPApp.swift
// Final Production Version

import SwiftUI
import SwiftData

@main
struct InigoVIPApp: App {
    // Services
    @State private var swiftDataService = SwiftDataService()
    @State private var supabaseService = SupabaseService()
    @State private var noteManager: NoteManager?
    @State private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let noteManager = noteManager {
                    NavigationStack(path: $router.path) {
                        NoteListView()
                            .environment(noteManager)
                            .environment(router)
                            .navigationDestination(for: Route.self) { route in
                                RouterView.destination(for: route)
                                    .environment(noteManager)
                                    .environment(router)
                            }
                    }
                    .sheet(item: $router.presentedSheet) { route in
                        RouterView.destination(for: route)
                            .environment(noteManager)
                            .environment(router)
                    }
                    .fullScreenCover(item: $router.presentedFullScreen) { route in
                        RouterView.destination(for: route)
                            .environment(noteManager)
                            .environment(router)
                    }
                } else {
                    // Initialization screen
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Initializing...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .task {
                // Initialize NoteManager on first launch
                if noteManager == nil {
                    noteManager = NoteManager(
                        swiftDataService: swiftDataService,
                        supabaseService: supabaseService
                    )
                    print("✅ App initialized successfully")
                }
            }
        }
    }
}
