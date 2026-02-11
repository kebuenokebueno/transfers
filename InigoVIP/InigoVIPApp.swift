// MARK: - InigoVIP App Entry Point (Final)
// File: InigoVIPApp.swift
// Final Production Version with SwiftDataService

import SwiftUI
import SwiftData

@main
struct InigoVIPApp: App {
    // Services
    @State private var swiftDataService = SwiftDataService()
    @State private var supabaseService = SupabaseService()
    @State private var noteWorker: NoteWorker?
    @State private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let noteWorker = noteWorker {
                    NavigationStack(path: $router.path) {
                        NoteListView()
                            .environment(noteWorker)
                            .environment(swiftDataService)
                            .environment(router)
                            .navigationDestination(for: Route.self) { route in
                                RouterView.destination(for: route)
                                    .environment(noteWorker)
                                    .environment(swiftDataService)
                                    .environment(router)
                            }
                    }
                    .sheet(item: $router.presentedSheet) { route in
                        RouterView.destination(for: route)
                            .environment(noteWorker)
                            .environment(swiftDataService)
                            .environment(router)
                    }
                    .modelContainer(for: NoteEntity.self)
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
                // Initialize NoteWorker on first launch
                if noteWorker == nil {
                    noteWorker = NoteWorker(
                        swiftDataService: swiftDataService,
                        supabaseService: supabaseService
                    )
                    print("✅ App initialized successfully")
                }
            }
        }
    }
}
