//
//  AddNoteInteractorTests.swift
//  InigoVIPTests
//

import Testing
import Foundation
@testable import InigoVIP

@MainActor
@Suite("AddNote Interactor Tests", .tags(.unit, .interactor))
struct AddNoteInteractorTests {

    private func makeSUT() -> (
        interactor: AddNoteInteractor,
        presenter: MockAddNotePresenter,
        worker: MockNoteWorker,
        swiftData: MockSwiftDataService
    ) {
        let swiftData  = MockSwiftDataService()
        let supabase   = MockSupabaseService()
        let worker     = MockNoteWorker(swiftDataService: swiftData, supabaseService: supabase)
        let interactor = AddNoteInteractor(noteWorker: worker)
        let presenter  = MockAddNotePresenter()
        interactor.presenter = presenter
        return (interactor, presenter, worker, swiftData)
    }

    @Test("Save note – expense stored as negative amount")
    func saveNoteExpense() async {
        let (interactor, presenter, worker, swiftData) = makeSUT()

        await interactor.saveNote(request: AddNoteScene.SaveNote.Request(
            amount: 75.00,
            description: "Coffee Shop",
            category: "Food",
            isIncome: false
        ))

        #expect(presenter.presentSaveResultCalled == true)
        #expect(presenter.lastSaveResponse?.success == true)
        #expect(worker.createNoteCallCount == 1)
        #expect(swiftData.notes.count == 1)
        #expect(swiftData.notes.first?.amount == -75.00)
        #expect(swiftData.notes.first?.noteDescription == "Coffee Shop")
    }

    @Test("Save note – income flag keeps amount positive")
    func saveNoteIncome() async {
        let (interactor, presenter, _, swiftData) = makeSUT()

        await interactor.saveNote(request: AddNoteScene.SaveNote.Request(
            amount: 2500.00,
            description: "Salary",
            category: "Income",
            isIncome: true
        ))

        #expect(presenter.lastSaveResponse?.success == true)
        #expect(swiftData.notes.first?.amount == 2500.00)
    }

    @Test("Save note – multiple notes accumulate")
    func saveNoteMultiple() async {
        let (interactor, _, _, swiftData) = makeSUT()

        for i in 1...3 {
            await interactor.saveNote(request: AddNoteScene.SaveNote.Request(
                amount: Double(i * 10),
                description: "Note \(i)",
                category: "Food",
                isIncome: false
            ))
        }

        #expect(swiftData.notes.count == 3)
    }

    @Test("Save note – nil presenter does not crash")
    func saveNoteNilPresenter() async {
        let (interactor, _, _, _) = makeSUT()
        interactor.presenter = nil

        await interactor.saveNote(request: AddNoteScene.SaveNote.Request(
            amount: 10.00,
            description: "Test",
            category: "Other",
            isIncome: false
        ))
        #expect(true)
    }
}
