//
//  MockClasses.swift
//  TransfersTests
//

import Foundation
import Testing
import SwiftData
import SwiftUI
@testable import Transfers

// MARK: - Tags

extension Tag {
    @Tag static var unit: Self
    @Tag static var viewModel: Self
    @Tag static var integration: Self
    @Tag static var performance: Self
    @Tag static var swiftdata: Self
    @Tag static var supabase: Self
    @Tag static var e2e: Self
}

// MARK: - Custom Error Types

enum TransferError: Error, Equatable {
    case notFound
    case saveFailed
    case deleteFailed
    case syncFailed
    case connectionFailed
    case timeout
}

// MARK: - Mock SwiftDataService

class MockSwiftDataService: SwiftDataServiceProtocol {
    var transfers: [TransferEntity] = []
    var saveCount = 0
    var updateCount = 0
    var deleteCount = 0
    var shouldFailOnSave = false
    var shouldFailOnDelete = false
    var shouldFailOnFetch = false

    func saveTransfer(_ transfer: TransferEntity) throws {
        saveCount += 1
        if shouldFailOnSave { throw TransferError.saveFailed }
        if let idx = transfers.firstIndex(where: { $0.id == transfer.id }) {
            transfers[idx] = transfer
        } else {
            transfers.append(transfer)
        }
    }

    func fetchTransfers() throws -> [TransferEntity] {
        if shouldFailOnFetch { throw TransferError.notFound }
        return transfers.sorted { $0.date > $1.date }
    }

    func fetchTransfer(id: String) throws -> TransferEntity? {
        if shouldFailOnFetch { throw TransferError.notFound }
        return transfers.first(where: { $0.id == id })
    }

    func updateTransfer(_ transfer: TransferEntity) throws {
        updateCount += 1
        if shouldFailOnSave { throw TransferError.saveFailed }
        guard let idx = transfers.firstIndex(where: { $0.id == transfer.id }) else {
            throw TransferError.notFound
        }
        transfers[idx] = transfer
    }

    func deleteTransfer(id: String) throws {
        deleteCount += 1
        if shouldFailOnDelete { throw TransferError.deleteFailed }
        guard transfers.contains(where: { $0.id == id }) else {
            throw TransferError.notFound
        }
        transfers.removeAll(where: { $0.id == id })
    }

    func searchTransfers(query: String) throws -> [TransferEntity] {
        let q = query.lowercased()
        return transfers.filter {
            $0.transferDescription.lowercased().contains(q) ||
            $0.category.lowercased().contains(q)
        }
    }

    func fetchTransfersByCategory(category: String) throws -> [TransferEntity] {
        return transfers.filter { $0.category == category }
    }

    func fetchPendingTransfers() throws -> [TransferEntity] {
        return transfers.filter { $0.syncStatus == "pending" }
    }

    func seed(_ transferArray: [TransferEntity]) { transfers = transferArray }

    func reset() {
        transfers = []
        saveCount = 0
        updateCount = 0
        deleteCount = 0
        shouldFailOnSave = false
        shouldFailOnDelete = false
        shouldFailOnFetch = false
    }
}

// MARK: - Mock SupabaseService

class MockSupabaseService {
    var transfers: [TransferEntity] = []
    var createCount = 0
    var updateCount = 0
    var deleteCount = 0
    var shouldFail = false
    var delayMilliseconds: UInt64 = 0

    func fetchTransfers() async throws -> [TransferEntity] {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
        if shouldFail { throw TransferError.connectionFailed }
        return transfers
    }

    func createTransfer(_ transfer: TransferEntity) async throws {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
        if shouldFail { throw TransferError.connectionFailed }
        createCount += 1
        transfers.append(transfer)
    }

    func updateTransfer(_ transfer: TransferEntity) async throws {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
        if shouldFail { throw TransferError.connectionFailed }
        updateCount += 1
        if let idx = transfers.firstIndex(where: { $0.id == transfer.id }) { transfers[idx] = transfer }
    }

    func deleteTransfer(id: String) async throws {
        if delayMilliseconds > 0 { try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000) }
        if shouldFail { throw TransferError.connectionFailed }
        deleteCount += 1
        transfers.removeAll(where: { $0.id == id })
    }

    func reset() {
        transfers = []
        createCount = 0
        updateCount = 0
        deleteCount = 0
        shouldFail = false
        delayMilliseconds = 0
    }
}

// MARK: - Mock TransferWorker

class MockTransferWorker: TransferWorkerProtocol {
    let swiftDataService: MockSwiftDataService
    let supabaseService: MockSupabaseService

    var isLoading = false
    var lastError: String?

    var fetchTransfersCallCount = 0
    var createTransferCallCount = 0
    var updateTransferCallCount = 0
    var deleteTransferCallCount = 0

    init(
        swiftDataService: MockSwiftDataService = MockSwiftDataService(),
        supabaseService: MockSupabaseService = MockSupabaseService()
    ) {
        self.swiftDataService = swiftDataService
        self.supabaseService = supabaseService
    }

    func fetchTransfers() async {
        fetchTransfersCallCount += 1
        isLoading = true
        lastError = nil
        do { _ = try swiftDataService.fetchTransfers() } catch { lastError = error.localizedDescription }
        isLoading = false
    }

    func createTransfer(_ transfer: TransferEntity) async {
        createTransferCallCount += 1
        do {
            try swiftDataService.saveTransfer(transfer)
            try await supabaseService.createTransfer(transfer)
        } catch { lastError = error.localizedDescription }
    }

    func updateTransfer(_ updatedTransfer: TransferEntity) async {
        updateTransferCallCount += 1
        do {
            guard let existing = try swiftDataService.fetchTransfer(id: updatedTransfer.id) else {
                lastError = "Transfer not found"
                return
            }
            existing.amount = updatedTransfer.amount
            existing.transferDescription = updatedTransfer.transferDescription
            existing.category = updatedTransfer.category
            existing.markForSync()
            try swiftDataService.updateTransfer(existing)
            try await supabaseService.updateTransfer(existing)
        } catch { lastError = error.localizedDescription }
    }

    func deleteTransfer(id: String) async {
        deleteTransferCallCount += 1
        do {
            try swiftDataService.deleteTransfer(id: id)
            try await supabaseService.deleteTransfer(id: id)
        } catch { lastError = error.localizedDescription }
    }

    func reset() {
        swiftDataService.reset()
        supabaseService.reset()
        fetchTransfersCallCount = 0
        createTransferCallCount = 0
        updateTransferCallCount = 0
        deleteTransferCallCount = 0
        lastError = nil
    }
}

// MARK: - Mock Router

@MainActor
class MockRouter: Router {
    var navigateToCallCount = 0
    var lastNavigatedRoute: Route?
    var presentSheetCallCount = 0
    var lastPresentedSheet: Route?
    var dismissCallCount = 0
    var navigateBackCallCount = 0
    
    override func navigate(to route: Route) {
        navigateToCallCount += 1
        lastNavigatedRoute = route
        super.navigate(to: route)
    }
    
    override func present(sheet route: Route) {
        presentSheetCallCount += 1
        lastPresentedSheet = route
        super.present(sheet: route)
    }
    
    override func dismiss() {
        dismissCallCount += 1
        super.dismiss()
    }
    
    override func navigateBack() {
        navigateBackCallCount += 1
        super.navigateBack()
    }
    
    func reset() {
        navigateToCallCount = 0
        lastNavigatedRoute = nil
        presentSheetCallCount = 0
        lastPresentedSheet = nil
        dismissCallCount = 0
        navigateBackCallCount = 0
        path = NavigationPath()
        presentedSheet = nil
    }
}

// MARK: - Test Data Builder

struct TestDataBuilder {
    static func createTransfer(
        id: String = "test_1",
        amount: Double = -100.0,
        description: String = "Test Transfer",
        date: Date = Date(),
        category: String = "Food",
        syncStatus: String = "pending"
    ) -> TransferEntity {
        TransferEntity(
            id: id,
            amount: amount,
            description: description,
            date: date,
            category: category,
            syncStatus: TransferEntity.SyncStatus(rawValue: syncStatus)!
        )
    }

    static func createTransfers(count: Int) -> [TransferEntity] {
        return (1...count).map { i in
            let transferId = "transfer_\(i)"
            let amount = (i % 3 == 0) ? Double(i * 100) : -Double(i * 10)
            let description = "Transfer \(i)"
            let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
            let category = categories[i % 6]

            return createTransfer(
                id: transferId,
                amount: amount,
                description: description,
                category: category)
        }
    }

    static func createMixedTransfers() -> [TransferEntity] {
        [
            createTransfer(id: "1", amount: -45.50,  description: "Grocery Store",  category: "Food"),
            createTransfer(id: "2", amount: -120.00, description: "Electric Bill",  category: "Utilities"),
            createTransfer(id: "3", amount: 2500.00, description: "Salary",         category: "Income"),
            createTransfer(id: "4", amount: -30.00,  description: "Gas Station",    category: "Transport"),
            createTransfer(id: "5", amount: 150.00,  description: "Freelance Work", category: "Income")
        ]
    }
}
