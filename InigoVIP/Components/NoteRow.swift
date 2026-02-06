//
//  NoteRow.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI


struct NoteRow: View {
    let note: NoteEntity
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            CategoryIcon(category: note.category)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(note.noteDescription)
                    .font(.headline)
                
                HStack {
                    Text(note.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(note.shortDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Sync indicator
                    if note.syncStatusEnum == .pending {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            Text(note.formattedAmount)
                .font(.headline)
                .foregroundColor(note.isPositive ? .green : .primary)
        }
        .padding(.vertical, 4)
    }
}
