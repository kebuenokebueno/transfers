//
//  TransferListPresenter.swift
//  Transfers
//

import Foundation

protocol TransferListPresentationLogic {
    func presentTransfers(response: TransferScene.FetchTransfers.Response)
    func presentDeleteResult(response: TransferScene.DeleteTransfer.Response)
}

@MainActor
class TransferListPresenter: TransferListPresentationLogic {
    weak var viewController: TransferListDisplayLogic?

    func presentTransfers(response: TransferScene.FetchTransfers.Response) {
        let displayedTransfers = response.transfers.map { transfer in
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
        let viewModel = TransferScene.FetchTransfers.ViewModel(displayedTransfers: displayedTransfers)
        viewController?.displayTransfers(viewModel: viewModel)
    }

    func presentDeleteResult(response: TransferScene.DeleteTransfer.Response) {
        let viewModel = TransferScene.DeleteTransfer.ViewModel(
            success: response.success,
            message: response.success ? "Transfer deleted" : "Failed to delete transfer"
        )
        viewController?.displayDeleteResult(viewModel: viewModel)
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
