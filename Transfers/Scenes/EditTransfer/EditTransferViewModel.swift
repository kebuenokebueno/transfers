//
//  EditTransferViewModel.swift
//  Transfers
//
//  MVVM ViewModel for EditTransfer scene
//

import Foundation

@MainActor
@Observable
final class EditTransferViewModel {
    
    // MARK: - Dependencies
    
    private let transferWorker: TransferWorkerProtocol
    private let swiftDataService: SwiftDataServiceProtocol
    private let router: Router
    
    // MARK: - Published State (Form Fields)
    
    var amount = ""
    var description = ""
    var category = ""
    var isPositive = true
    
    // MARK: - Published State (UI State)
    
    private(set) var isLoading = true
    private(set) var isSaving = false
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
    
    func saveTransfer(transferId: String) {
        guard let value = Double(amount) else { return }
        isSaving = true
        Task {
            await performSaveTransfer(
                transferId: transferId,
                amount: value,
                description: description,
                category: category,
                isPositive: isPositive
            )
        }
    }
    
    // MARK: - Business Logic
    
    private func fetchTransfer(transferId: String) async {
        guard let transfer = try? swiftDataService.fetchTransfer(id: transferId) else {
            amount = ""
            description = ""
            category = ""
            isLoading = false
            return
        }
        
        amount = String(abs(transfer.amount))
        description = transfer.transferDescription
        category = transfer.category
        isPositive = transfer.isPositive
        isLoading = false
    }
    
    private func performSaveTransfer(
        transferId: String,
        amount: Double,
        description: String,
        category: String,
        isPositive: Bool
    ) async {
        guard let existing = try? swiftDataService.fetchTransfer(id: transferId) else {
            isSaving = false
            errorMessage = "Failed to update transfer"
            return
        }
        
        existing.amount = isPositive ? amount : -amount
        existing.transferDescription = description
        existing.category = category
        
        await transferWorker.updateTransfer(existing)
        
        isSaving = false
        router.navigateBack()
    }
}
