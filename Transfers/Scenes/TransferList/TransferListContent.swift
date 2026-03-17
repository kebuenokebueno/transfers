//
//  TransferListContent.swift
//  Transfers
//

import Foundation
import SwiftUI

// MARK: - Vista pura (testable)
struct TransferListContent: View {
    let transfers: [TransferViewModel]          // ← ViewModel, no Entity
    var isLoading: Bool = false
    var lastError: String? = nil
    var onTapTransfer: ((TransferViewModel) -> Void)? = nil
    var onDeleteTransfer: ((TransferViewModel) -> Void)? = nil
    var onAddTransfer: (() -> Void)? = nil
    var onFetch: (() -> Void)? = nil
    var onClearError: (() -> Void)? = nil

    var body: some View {
        List {
            ForEach(transfers) { transfer in
                TransferRow(transfer: transfer)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapTransfer?(transfer)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onDeleteTransfer?(transfer)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Transfers")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onAddTransfer?()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView("Loading...")
            } else if transfers.isEmpty {
                ContentUnavailableView(
                    "No Transfers",
                    systemImage: "transfer.text",
                    description: Text("Tap + to add your first transfer")
                )
            }
        }
        .alert("Error", isPresented: .constant(lastError != nil)) {
            Button("OK") { onClearError?() }
        } message: {
            if let error = lastError { Text(error) }
        }
        .onAppear {
            onFetch?()
        }
        .refreshable {
            onFetch?()
        }
    }
}
