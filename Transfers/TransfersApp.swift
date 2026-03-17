import SwiftUI
import SwiftData

@main
struct TransfersApp: App {
    // Services
    @State private var swiftDataService = SwiftDataService()
    @State private var supabaseService = SupabaseService()
    @State private var transferWorker: TransferWorker?
    @State private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let transferWorker = transferWorker {
                    NavigationStack(path: $router.path) {
                        TransferListView()
                            .environment(transferWorker)
                            .environment(swiftDataService)
                            .environment(router)
                            .navigationDestination(for: Route.self) { route in
                                RouterView.destination(for: route)
                                    .environment(transferWorker)
                                    .environment(swiftDataService)
                                    .environment(router)
                            }
                    }
                    .sheet(item: $router.presentedSheet) { route in
                        RouterView.destination(for: route)
                            .environment(transferWorker)
                            .environment(swiftDataService)
                            .environment(router)
                    }
                    .modelContainer(for: TransferEntity.self)
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
                // Initialize TransferWorker on first launch
                if transferWorker == nil {
                    transferWorker = TransferWorker(
                        swiftDataService: swiftDataService,
                        supabaseService: supabaseService
                    )
                    print("✅ App initialized successfully")
                }
            }
        }
    }
}
