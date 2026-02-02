//
//  NoteListContentView.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import Foundation
import SwiftUI

public struct NoteListContentView: View {
    @Bindable var viewController: NoteListViewController
    let router: Router
    
    public var body: some View {
        List {
            ForEach(viewController.displayedNotes) { note in
                NoteRowVIP(note: note)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.navigate(to: .noteDetail(id: note.id))
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewController.deleteNote(noteId: note.id)
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
                    router.present(sheet: .addNote)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewController.isLoading {
                ProgressView("Loading...")
            } else if viewController.displayedNotes.isEmpty {
                ContentUnavailableView(
                    "No Notes",
                    systemImage: "note.text",
                    description: Text("Tap + to add your first note")
                )
            }
        }
        .alert("Success", isPresented: .constant(viewController.successMessage != nil)) {
            Button("OK") {
                viewController.successMessage = nil
            }
        } message: {
            if let message = viewController.successMessage {
                Text(message)
            }
        }
        .alert("Error", isPresented: .constant(viewController.errorMessage != nil)) {
            Button("OK") {
                viewController.errorMessage = nil
            }
        } message: {
            if let error = viewController.errorMessage {
                Text(error)
            }
        }
        .refreshable {
            viewController.loadNotes()
        }
    }
}

struct NoteRowVIP: View {
    let note: NoteScene.FetchNotes.ViewModel.DisplayedNote
    
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
