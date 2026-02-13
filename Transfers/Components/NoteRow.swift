//
//  NoteRow.swift
//  Transfers
//

import SwiftUI

struct NoteRow: View {
    let note: NoteViewModel

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: note.category)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(note.description)
                    .font(.headline)

                HStack {
                    Text(note.category)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(note.date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if note.syncStatus == "Pending" {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            Text(note.amount)
                .font(.headline)
                .foregroundColor(note.isPositive ? .green : .primary)
        }
        .padding(.vertical, 4)
    }
}
