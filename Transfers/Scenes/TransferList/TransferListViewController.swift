import Foundation

protocol TransferListDisplayLogic: AnyObject {
    func displayTransfers(viewModel: TransferScene.FetchTransfers.ViewModel)
    func displayDeleteResult(viewModel: TransferScene.DeleteTransfer.ViewModel)
}

@MainActor
@Observable
class TransferListViewController: TransferListDisplayLogic {
    var interactor: TransferListBusinessLogic?
    var router: TransferListRoutingLogic?

    // View State
    var displayedNotes: [TransferViewModel] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Display (called by Presenter)

    func displayTransfers(viewModel: TransferScene.FetchTransfers.ViewModel) {
        displayedNotes = viewModel.displayedNotes
        isLoading = false
    }

    func displayDeleteResult(viewModel: TransferScene.DeleteTransfer.ViewModel) {
        if !viewModel.success { errorMessage = viewModel.message }
    }

    // MARK: - User Actions → Interactor (business logic)

    func loadTransfers() {
        isLoading = true
        Task { await interactor?.fetchTransfers() }
    }

    func deleteTransfer(transferId: String) {
        Task {
            await interactor?.deleteTransfer(request: .init(transferId: transferId))
        }
    }

    // MARK: - User Actions → Router (navigation)

    func didSelectNote(transferId: String) {
        router?.routeToTransferDetail(transferId: transferId)
    }

    func didTapAddTransfer() {
        router?.routeToAddTransfer()
    }

    func didTapEditTransfer(transferId: String) {
        router?.routeToEditTransfer(transferId: transferId)
    }
}
