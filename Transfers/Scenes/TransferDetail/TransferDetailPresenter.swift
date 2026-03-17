//
//  TransferDetailPresenter.swift
//  Transfers
//

import Foundation

protocol TransferDetailPresentationLogic {
    func presentTransfer(response: TransferDetailScene.FetchTransfer.Response)
    func presentDeleteResult(response: TransferDetailScene.DeleteTransfer.Response)
}

@MainActor
class TransferDetailPresenter: TransferDetailPresentationLogic {
    weak var viewController: TransferDetailDisplayLogic?

    func presentTransfer(response: TransferDetailScene.FetchTransfer.Response) {
        let vm = response.transfer.map { transfer in
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
        viewController?.displayTransfer(viewModel: .init(transfer: vm))
    }

    func presentDeleteResult(response: TransferDetailScene.DeleteTransfer.Response) {
        let vm = TransferDetailScene.DeleteTransfer.ViewModel(
            success: response.success,
            message: response.success ? "Transfer deleted" : "Failed to delete transfer"
        )
        viewController?.displayDeleteResult(viewModel: vm)
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
