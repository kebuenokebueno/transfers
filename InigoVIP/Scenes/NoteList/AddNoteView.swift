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
    @State private var viewController: NoteListViewController?
    
    @State private var amount = ""
    @State private var description = ""
    @State private var category = "Food"
    @State private var isIncome = false
    @Environment(NoteManager.self) private var noteManager

    
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
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveNote()
                        }
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
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
        }
        .task {
            if viewController == nil {
                setupVIP()
            }
        }
    }
    
    private func setupVIP() {
        let interactor = NoteListInteractor(noteManager: noteManager)
        let presenter = NoteListPresenter()
        let vc = NoteListViewController()
        
        vc.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        
        viewController = vc
    }
    
    private func saveNote() async {
        guard let amountValue = Double(amount) else { return }
        let x = NoteScene.CreateNote.Request(
            amount: amountValue,
            description: description,
            category: category,
            isIncome: isIncome
        )
        await viewController?.interactor?.createNote(
            request: x
        )
    }
}
