//
//  TransferDetailViewModel.swift
//  Transfers
//
//  MVVM ViewModel for TransferDetail scene
//

import Foundation

@MainActor
@Observable
final class TransferDetailViewModel {
    
    // MARK: - Dependencies
    
    private let transferWorker: TransferWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol
    private let router: Router
    
    // MARK: - Published State
    
    private(set) var transfer: TransferViewModel?
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
    
    func loadTransfer(transferId: String) {
        Task {
            await fetchTransfer(transferId: transferId)
        }
    }
    
    func deleteTransfer(transferId: String) {
        Task {
            await performDeleteTransfer(transferId: transferId)
        }
    }
    
    func didTapEdit(transferId: String) {
        router.navigate(to: .editTransfer(id: transferId))
    }
    
    // MARK: - Business Logic
    
    private func fetchTransfer(transferId: String) async {
        let entity = try? swiftDataService.fetchTransfer(id: transferId)
        transfer = entity.map { formatTransfer($0) }
    }
    
    private func performDeleteTransfer(transferId: String) async {
        await transferWorker.deleteTransfer(id: transferId)
        router.navigateBack()
    }
    
    // MARK: - Presentation Logic
    
    private func formatTransfer(_ transfer: TransferEntity) -> TransferViewModel {
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
