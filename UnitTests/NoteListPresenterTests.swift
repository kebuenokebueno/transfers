//
//  NoteListPresenterTests.swift
//  InigoVIPTests
//

import Testing
import Foundation
@testable import InigoVIP

@Suite("NoteList Presenter Tests", .tags(.unit, .presenter))
struct NoteListPresenterTests {

    @MainActor
    private func makeSUT() -> (presenter: NoteListPresenter, vc: MockNoteListViewController) {
        let presenter = NoteListPresenter()
        let vc        = MockNoteListViewController()
        presenter.viewController = vc
        return (presenter, vc)
    }

    // MARK: - Present Notes

    @MainActor @Test("Present notes - formats expense with minus and euro")
    func presentNotesFormatsExpense() {
        let (presenter, vc) = makeSUT()
        let note = TestDataBuilder.createNote(id: "1", amount: -45.50, description: "Grocery Store", category: "Food")
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [note]))
        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(vc.displayNotesCalled == true)
        #expect(displayed?.amount.contains("45") == true)
        #expect(displayed?.amount.contains("-") == true)
        #expect(displayed?.isPositive == false)
    }

    @MainActor @Test("Present notes - formats income with plus")
    func presentNotesFormatsIncome() {
        let (presenter, vc) = makeSUT()
        let note = TestDataBuilder.createNote(id: "2", amount: 2500.00, description: "Salary", category: "Income")
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [note]))
        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(displayed?.isPositive == true)
        #expect(displayed?.amount.contains("+") == true)
        #expect(displayed?.category == "Income")
    }

    @MainActor @Test("Present notes - formats date correctly")
    func presentNotesFormatsDate() {
        let (presenter, vc) = makeSUT()
        let testDate = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 25))!
        let note = TestDataBuilder.createNote(id: "1", amount: -10.0, date: testDate)
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [note]))
        let displayed = vc.lastFetchViewModel?.displayedNotes.first
        #expect(displayed?.date.contains("Jan") == true || displayed?.date.contains("2026") == true)
    }

    @MainActor @Test("Present notes - empty list still calls ViewController")
    func presentNotesEmpty() {
        let (presenter, vc) = makeSUT()
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: []))
        #expect(vc.displayNotesCalled == true)
        #expect(vc.lastFetchViewModel?.displayedNotes.isEmpty == true)
    }

    @MainActor @Test("Present notes - preserves order")
    func presentNotesOrder() {
        let (presenter, vc) = makeSUT()
        let notes = [
            TestDataBuilder.createNote(id: "A", description: "First"),
            TestDataBuilder.createNote(id: "B", description: "Second"),
            TestDataBuilder.createNote(id: "C", description: "Third")
        ]
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: notes))
        let displayed = vc.lastFetchViewModel?.displayedNotes ?? []
        #expect(displayed.count == 3)
        #expect(displayed[0].id == "A")
        #expect(displayed[1].id == "B")
        #expect(displayed[2].id == "C")
    }

    @MainActor @Test("Present notes - zero amount treated as positive")
    func presentNotesZeroAmount() {
        let (presenter, vc) = makeSUT()
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [
            TestDataBuilder.createNote(id: "z", amount: 0.0)
        ]))
        #expect(vc.lastFetchViewModel?.displayedNotes.first?.isPositive == true)
    }

    @MainActor @Test("Present notes - nil ViewController does not crash")
    func presentNotesNilVC() {
        let presenter = NoteListPresenter()
        presenter.viewController = nil
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [
            TestDataBuilder.createNote(id: "x")
        ]))
        #expect(true)
    }

    @MainActor @Test("Present notes - called twice, VC sees latest")
    func presentNotesMultipleCalls() {
        let (presenter, vc) = makeSUT()
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: [TestDataBuilder.createNote(id: "1")]))
        presenter.presentNotes(response: NoteScene.FetchNotes.Response(notes: TestDataBuilder.createMixedNotes()))
        #expect(vc.displayNotesCallCount == 2)
        #expect(vc.lastFetchViewModel?.displayedNotes.count == 5)
    }

    // MARK: - Present Delete Result

    @MainActor @Test("Present delete result - success carries message")
    func presentDeleteSuccess() {
        let (presenter, vc) = makeSUT()
        presenter.presentDeleteResult(response: NoteScene.DeleteNote.Response(success: true, noteId: "del_1"))
        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == true)
        #expect(vc.lastDeleteViewModel?.message != nil)
    }

    @MainActor @Test("Present delete result - failure carries message")
    func presentDeleteFailure() {
        let (presenter, vc) = makeSUT()
        presenter.presentDeleteResult(response: NoteScene.DeleteNote.Response(success: false, noteId: "del_fail"))
        #expect(vc.displayDeleteResultCalled == true)
        #expect(vc.lastDeleteViewModel?.success == false)
        #expect(vc.lastDeleteViewModel?.message != nil)
    }
}
