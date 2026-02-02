//
//  AddNoteView.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI
import UIKit
import StoreKit

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NoteWorker.self) private var noteWorker
    @Environment(SwiftDataService.self) private var swiftDataService
    
    @State private var viewController: NoteListViewController?
    @State private var amount = ""
    @State private var description = ""
    @State private var category = "Food"
    @State private var isIncome = false
    @State private var isSaving = false
    
    let categories = ["Food", "Utilities", "Income", "Transport", "Entertainment", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $isIncome) {
                        Text("Expense").tag(false)
                        Text("Income").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(amount.isEmpty || description.isEmpty || isSaving)
                }
            }
            .disabled(isSaving)
            .overlay {
                if isSaving {
                    ProgressView("Saving...")
                }
            }
            .alert("Success", isPresented: .constant(viewController?.successMessage != nil)) {
                Button("OK") {
                    viewController?.successMessage = nil
                    dismiss()
                }
            } message: {
                if let message = viewController?.successMessage {
                    Text(message)
                }
            }
            .alert("Error", isPresented: .constant(noteWorker.lastError != nil)) {
                Button("OK") {
                    noteWorker.lastError = nil
                }
            } message: {
                if let error = noteWorker.lastError {
                    Text(error)
                }
            }
        }
        .task {
            if viewController == nil {
                setupVIP()
            }
        }
    }
    
    private func setupVIP() {
        // ✅ Pass both noteWorker AND swiftDataService
        let interactor = NoteListInteractor(
            noteWorker: noteWorker,
            swiftDataService: swiftDataService
        )
        let presenter = NoteListPresenter()
        let vc = NoteListViewController()
        
        vc.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        
        viewController = vc
    }
    
    private func saveNote() {
        guard let amountValue = Double(amount) else { return }
        
        isSaving = true
        
        Task {
            await viewController?.interactor?.createNote(
                request: NoteScene.CreateNote.Request(
                    amount: amountValue,
                    description: description,
                    category: category,
                    isIncome: isIncome
                )
            )
            
            isSaving = false
            
            // Wait a moment then dismiss
            try? await Task.sleep(for: .milliseconds(500))
            dismiss()
        }
    }
}
