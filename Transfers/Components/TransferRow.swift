//
//  TransferRow.swift
//  Transfers
//

import SwiftUI

struct TransferRow: View {
    let transfer: TransferViewModel

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: transfer.category)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(transfer.description)
                    .font(.headline)

                HStack {
                    Text(transfer.category)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(transfer.date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if transfer.syncStatus == "Pending" {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            Text(transfer.amount)
                .font(.headline)
                .foregroundColor(transfer.isPositive ? .green : .primary)
        }
        .padding(.vertical, 4)
    }
}
