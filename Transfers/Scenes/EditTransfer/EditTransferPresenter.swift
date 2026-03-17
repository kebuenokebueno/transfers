//
//  EditTransferPresenter.swift
//  Transfers
//

import Foundation

protocol EditTransferPresentationLogic {
    func presentTransfer(response: EditTransferScene.LoadTransfer.Response)
    func presentSaveResult(response: EditTransferScene.SaveTransfer.Response)
}

protocol EditTransferDisplayLogic: AnyObject {
    func displayTransfer(viewModel: EditTransferScene.LoadTransfer.ViewModel)
    func displaySaveResult(viewModel: EditTransferScene.SaveTransfer.ViewModel)
}

@MainActor
class EditTransferPresenter: EditTransferPresentationLogic {
    weak var viewController: EditTransferDisplayLogic?

    func presentTransfer(response: EditTransferScene.LoadTransfer.Response) {
        guard let transfer = response.transfer else {
            viewController?.displayTransfer(viewModel: .init(transfer: nil, amount: "", description: "", category: ""))
            return
        }
        let vm = TransferViewModel(
            id: transfer.id,
            amount: formatAmount(transfer.amount),
            description: transfer.transferDescription,
            date: formatDate(transfer.date),
            category: transfer.category,
            isPositive: transfer.isPositive,
            syncStatus: transfer.syncStatusEnum.rawValue.capitalized
        )
        viewController?.displayTransfer(viewModel: .init(
            transfer: vm,
            amount: String(abs(transfer.amount)),
            description: transfer.transferDescription,
            category: transfer.category
        ))
    }

    func presentSaveResult(response: EditTransferScene.SaveTransfer.Response) {
        let vm = EditTransferScene.SaveTransfer.ViewModel(
            success: response.success,
            message: response.success ? "Transfer updated successfully" : "Failed to update transfer"
        )
        viewController?.displaySaveResult(viewModel: vm)
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
