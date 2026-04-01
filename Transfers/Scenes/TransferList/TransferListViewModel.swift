//
//  TransferListViewModel.swift
//  Transfers
//
//  MVVM ViewModel - combines business logic (Interactor), presentation (Presenter), and state (ViewController)
//

import Foundation

@MainActor
@Observable
final class TransferListViewModel {
    
    // MARK: - Dependencies
    
    private let transferWorker: TransferWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol
    private let router: Router
    
    // MARK: - Published State
    
    private(set) var displayedTransfers: [TransferViewModel] = []
    private(set) var isLoading = false
    var errorMessage: String?
    
    // MARK: - Init
    
    init(
        transferWorker: TransferWorkerProtocol,
        swiftDataService: SwiftDataServiceProtocol,
        router: Router
    ) {
        self.transferWorker = transferWorker
        self.swiftDataService = swiftDataService
        self.router = router
    }
    
    // MARK: - User Actions
    
    func loadTransfers() {
        isLoading = true
        Task {
            await fetchTransfers()
        }
    }
    
    func deleteTransfer(transferId: String) {
        Task {
            await performDeleteTransfer(transferId: transferId)
        }
    }
    
    func didSelectTransfer(transferId: String) {
        router.navigate(to: .transferDetail(id: transferId))
    }
    
    func didTapAddTransfer() {
        router.present(sheet: .addTransfer)
    }
    
    func didTapEditTransfer(transferId: String) {
        router.navigate(to: .editTransfer(id: transferId))
    }
    
    // MARK: - Business Logic (from Interactor)
    
    private func fetchTransfers() async {
        // Show local transfers first (optimistic UI)
        let localTransfers = (try? swiftDataService.fetchTransfers()) ?? []
        if !localTransfers.isEmpty {
            displayedTransfers = formatTransfers(localTransfers)
        }
        
        // Sync with remote
        await transferWorker.fetchTransfers()
        
        // Update with synced transfers
        let updatedTransfers = (try? swiftDataService.fetchTransfers()) ?? []
        displayedTransfers = formatTransfers(updatedTransfers)
        isLoading = false
    }
    
    private func performDeleteTransfer(transferId: String) async {
        await transferWorker.deleteTransfer(id: transferId)
        // Refresh list after deletion
        await fetchTransfers()
    }
    
    // MARK: - Presentation Logic (from Presenter)
    
    private func formatTransfers(_ transfers: [TransferEntity]) -> [TransferViewModel] {
        transfers.map { transfer in
            TransferViewModel(
                id: transfer.id,
                amount: formatAmount(transfer.amount),
                description: transfer.transferDescription,
                date: formatDate(transfer.date),
                category: transfer.category,
                isPositive: transfer.isPositive,
                syncStatus: transfer.syncStatusEnum.rawValue.capitalized
            )
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatted = String(format: "%.2f", abs(amount))
        return amount >= 0 ? "+€\(formatted)" : "-€\(formatted)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
