//
//  NoteListContent.swift
//  InigoVIP
//
//  Created by Inigo on 4/2/26.
//

import Foundation
import SwiftUI


// MARK: - Vista pura (testable)
struct NoteListContent: View {
    let notes: [NoteEntity]
    var isLoading: Bool = false
    var lastError: String? = nil
    var onTapNote: ((NoteEntity) -> Void)? = nil
    var onDeleteNote: ((NoteEntity) -> Void)? = nil
    var onAddNote: (() -> Void)? = nil
    var onFetch: (() async -> Void)? = nil
    var onClearError: (() -> Void)? = nil
    
    var body: some View {
        List {
            ForEach(notes) { note in
                NoteRow(note: note)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapNote?(note)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onDeleteNote?(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onAddNote?()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView("Loading...")
            } else if notes.isEmpty {
                ContentUnavailableView(
                    "No Notes",
                    systemImage: "note.text",
                    description: Text("Tap + to add your first note")
                )
            }
        }
        .alert("Error", isPresented: .constant(lastError != nil)) {
            Button("OK") {
                onClearError?()
            }
        } message: {
            if let error = lastError {
                Text(error)
            }
        }
        .task {
            await onFetch?()
        }
        .refreshable {
            await onFetch?()
        }
    }
}
