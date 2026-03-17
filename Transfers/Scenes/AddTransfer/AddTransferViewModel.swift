//
//  AddTransferViewModel.swift
//  Transfers
//
//  MVVM ViewModel for AddTransfer scene
//

import Foundation

@MainActor
@Observable
final class AddTransferViewModel {
    
    // MARK: - Dependencies
    
    private let transferWorker: TransferWorkerProtocol
    private let router: Router
    
    // MARK: - Published State
    
    private(set) var isSaving = false
    var errorMessage: String?
    
    // MARK: - Init
    
    init(transferWorker: TransferWorkerProtocol, router: Router) {
        self.transferWorker = transferWorker
        self.router = router
    }
    
    // MARK: - User Actions
    
    func saveTransfer(amount: Double, description: String, category: String, isIncome: Bool) {
        isSaving = true
        Task {
            await performSaveTransfer(
                amount: amount,
                description: description,
                category: category,
                isIncome: isIncome
            )
        }
    }
    
    func dismiss() {
        router.dismiss()
    }
    
    // MARK: - Business Logic
    
    private func performSaveTransfer(
        amount: Double,
        description: String,
        category: String,
        isIncome: Bool
    ) async {
        let transfer = TransferEntity(
            id: UUID().uuidString,
            amount: isIncome ? amount : -amount,
            description: description,
            date: Date(),
            category: category,
            syncStatus: .pending
        )
        
        await transferWorker.createTransfer(transfer)
        
        isSaving = false
        router.dismiss()
    }
}
