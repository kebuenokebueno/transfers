//
//  NoteListPresenterTests.swift
//  InigoVIPTests
//
//  Created by Inigo on 29/1/26.
//

import Testing
import Foundation
@testable import InigoVIP

// MARK: - Presenter Tests

@Suite("NoteList Presenter Tests", .tags(.unit, .presenter))
struct NoteListPresenterTests {

    // MARK: - Helper

    @MainActor private func makeSUT() -> (
        presenter: NoteListPresenter,
        vc: MockNoteListViewController
    ) {
        let presenter = NoteListPresenter()
        let vc        = MockNoteListViewController()
        presenter.viewController = vc
        return (presenter, vc)
    }

    // MARK: - Fetch Notes – formatting

    @MainActor @Test("Present notes – formats negative amount with € and minus sign")
    func presentNotesFormatsExpense() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "1", amount: -45.50, description: "Grocery Store", category: "Food")
        let response = NoteScene.FetchNotes.Response(notes: [note])

        presenter.presentNotes(response: response)

        #expect(vc.displayNotesCalled == true)
        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(displayed?.amount.contains("€") == true)
        #expect(displayed?.amount.contains("-") == true)
        #expect(displayed?.amount.contains("45") == true)
        #expect(displayed?.isPositive == false)
    }


    @MainActor @Test("Present notes – formats positive amount correctly")
    func presentNotesFormatsIncome() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "2", amount: 2500.00, description: "Salary", category: "Income")
        let response = NoteScene.FetchNotes.Response(notes: [note])

        presenter.presentNotes(response: response)

        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(displayed?.isPositive == true)
        #expect(displayed?.amount.contains("+") == true)
        #expect(displayed?.amount.contains("2") == true)
        #expect(displayed?.amount.contains("500") == true)
        #expect(displayed?.category == "Income")
    }

    
    @MainActor @Test("Present notes – formats date correctly")
    func presentNotesFormatsDate() {
        let (presenter, vc) = makeSUT()

        let testDate = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 25))!
        let note = TestDataBuilder.createNote(id: "1", amount: -10.0, date: testDate)
        let response = NoteScene.FetchNotes.Response(notes: [note])

        presenter.presentNotes(response: response)

        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(
            displayed?.date.contains("Jan") == true ||
            displayed?.date.contains("2026") == true,
            "Date should contain month or year"
        )
    }


    @MainActor @Test("Present notes – empty list still calls ViewController")
    func presentNotesEmpty() {
        let (presenter, vc) = makeSUT()

        let response = NoteScene.FetchNotes.Response(notes: [])
        presenter.presentNotes(response: response)

        #expect(vc.displayNotesCalled == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 0)
    }


    @MainActor @Test("Present notes – preserves order")
    func presentNotesOrder() {
        let (presenter, vc) = makeSUT()

        let notes = [
            TestDataBuilder.createNote(id: "A", description: "First"),
            TestDataBuilder.createNote(id: "B", description: "Second"),
            TestDataBuilder.createNote(id: "C", description: "Third")
        ]
        let response = NoteScene.FetchNotes.Response(notes: notes)
        presenter.presentNotes(response: response)

        let displayed = vc.lastFetchViewModel?.displayedNotes ?? []
        #expect(displayed.count == 3)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 3)
        #expect(displayed[0].id == "A")
        #expect(displayed[1].id == "B")
        #expect(displayed[2].id == "C")
    }


    @MainActor @Test("Present notes – zero amount treated as positive")
    func presentNotesZeroAmount() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "z", amount: 0.0)
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [note]))

        #expect(vc.lastFetchViewModel?.displayedNotes.first?.isPositive == true)
    }


    @MainActor @Test("Present notes – very large amount still has €")
    func presentNotesLargeAmount() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "big", amount: 1_000_000.99)
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [note]))

        #expect(vc.lastFetchViewModel?.displayedNotes.first?.amount.contains("€") == true)
    }


    @MainActor @Test("Present notes – nil viewController does not crash")
    func presentNotesNilVC() {
        let presenter = NoteListPresenter()
        presenter.viewController = nil          // deliberately nil

        let note = TestDataBuilder.createNote(id: "x", amount: 5.0)
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [note]))
        #expect(true, "No crash")
    }


    @MainActor @Test("Present notes – called twice, VC sees both")
    func presentNotesMultipleCalls() {
        let (presenter, vc) = makeSUT()

        presenter.presentNotes(response: NoteScene.FetchNotes.Response(
            notes: [TestDataBuilder.createNote(id: "1")]))
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(
            notes: TestDataBuilder.createMixedNotes()))

        #expect(vc.displayNotesCallCount == 2)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 5, "Latest batch wins")
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 5)
    }

    @MainActor @Test("Present create result – success carries message")
    func presentCreateSuccess() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "new_1", amount: -22.50, description: "Lunch")
        let response = NoteScene.CreateNote.Response(note: note, success: true)

        presenter.presentCreateResult(response: response)

        #expect(vc.displayCreateResultCalled == true)
        #expect(vc.lastCreateViewModel?.success == true)
        #expect(vc.lastCreateViewModel?.message != nil)
    }


    @MainActor @Test("Present create result – failure forwards error")
    func presentCreateFailure() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "fail_1")
        let response = NoteScene.CreateNote.Response(note: note, success: false)

        presenter.presentCreateResult(response: response)

        #expect(vc.displayCreateResultCalled == true)
        #expect(vc.lastCreateViewModel?.success == false)
        #expect(vc.lastCreateViewModel?.message != nil)
    }

    // MARK: - Update Note – formatting

    @MainActor @Test("Present update result – success carries message")
    func presentUpdateSuccess() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "upd_1", amount: 99.99, description: "Updated")
        let response = NoteScene.UpdateNote.Response(note: note, success: true)

        presenter.presentUpdateResult(response: response)

        #expect(vc.displayUpdateResultCalled == true)
        #expect(vc.lastUpdateViewModel?.success == true)
        #expect(vc.lastUpdateViewModel?.message != nil)
    }

  
    @MainActor @Test("Present update result – failure forwards error")
    func presentUpdateFailure() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "upd_fail")
        let response = NoteScene.UpdateNote.Response(note: note, success: false)

        presenter.presentUpdateResult(response: response)

        #expect(vc.displayUpdateResultCalled == true)
        #expect(vc.lastUpdateViewModel?.success == false)
        #expect(vc.lastUpdateViewModel?.message != nil)
    }

    // MARK: - Delete Note – formatting

    @MainActor @Test("Present delete result – success carries message")
    func presentDeleteSuccess() {
        let (presenter, vc) = makeSUT()

        let response = NoteScene.DeleteNote.Response(success: true, noteId: "del_1")

        presenter.presentDeleteResult(response: response)

        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == true)
        #expect(vc.lastDeleteViewModel?.message != nil)
    }

    
    @MainActor @Test("Present delete result – failure carries message")
    func presentDeleteFailure() {
        let (presenter, vc) = makeSUT()

        let response = NoteScene.DeleteNote.Response(success: false, noteId: "del_fail")

        presenter.presentDeleteResult(response: response)

        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == false)
        #expect(vc.lastDeleteViewModel?.message != nil)
    }

    // MARK: - Fetch Single Note – formatting

    @MainActor @Test("Present single note – formats all fields")
    func presentNoteSingle() {
        let (presenter, vc) = makeSUT()

        let note = TestDataBuilder.createNote(id: "det_1", amount: -88.00, description: "Detail Test", category: "Entertainment")
        let response = NoteScene.FetchNote.Response(note: note)

        presenter.presentNote(response: response)

        #expect(vc.displayNoteCalled == true)
        let vm = vc.lastNoteViewModel?.displayedNote
        #expect(vm?.id == "det_1")
        #expect(vm?.description == "Detail Test")
        #expect(vm?.category == "Entertainment")
        #expect(vm?.amount.contains("88") == true)
        #expect(vm?.isPositive == false)
    }


    @MainActor @Test("Present single note – nil note still calls ViewController")
    func presentNoteNil() {
        let (presenter, vc) = makeSUT()

        let response = NoteScene.FetchNote.Response(note: nil)
        presenter.presentNote(response: response)

        #expect(vc.displayNoteCalled == true)
        #expect(vc.lastNoteViewModel?.displayedNote == nil)
    }
}
