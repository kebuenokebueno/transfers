//
//  NoteListContent.swift
//  Transfers
//

import Foundation
import SwiftUI

// MARK: - Vista pura (testable)
struct NoteListContent: View {
    let notes: [NoteViewModel]          // ← ViewModel, no Entity
    var isLoading: Bool = false
    var lastError: String? = nil
    var onTapNote: ((NoteViewModel) -> Void)? = nil
    var onDeleteNote: ((NoteViewModel) -> Void)? = nil
    var onAddNote: (() -> Void)? = nil
    var onFetch: (() -> Void)? = nil
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
