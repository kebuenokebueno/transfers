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
    @State private var noteWorker: NoteWorker?
    @State private var router = Router()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if let noteWorker = noteWorker {
                    NavigationStack(path: $router.path) {
                        NoteListView()
                            .environment(noteWorker)
                            .environment(router)
                            .navigationDestination(for: Route.self) { route in
                                RouterView.destination(for: route)
                                    .environment(noteWorker)
                                    .environment(router)
                            }
                    }
                    .sheet(item: $router.presentedSheet) { route in
                        RouterView.destination(for: route)
                            .environment(noteWorker)
                            .environment(router)
                    }
                    .fullScreenCover(item: $router.presentedFullScreen) { route in
                        RouterView.destination(for: route)
                            .environment(noteWorker)
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
                // Initialize NoteWorker on first launch
                if noteWorker == nil {
                    noteWorker = NoteWorker(
                        swiftDataService: swiftDataService,
                        supabaseService: supabaseService
                    )
                    print("✅ App initialized successfully")
                }
                await noteWorker?.syncPendingNotes()
            }
        }
    }
}
