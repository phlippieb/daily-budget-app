import Testing
import Foundation

@testable import DailyBudget

@Test func testImportCsv() throws {
  // Given some CSV data with some budgets (one having two expenses), and
  // with some metadata that we should ignore
  let csvString = """
    #appVersion:1.5.0
    budgetUUID,budgetName,budgetNotes,budgetAmount,budgetFirstDay,budgetLastDay,expenseName,expenseNotes,expenseAmount,expenseDate
    DEADBEEF-0000-0000-0000-000000000000,My Budget,Notes for my budget,100,1990/01/01,1990/01/02,My expense 1,Notes for my expense,99,1990/01/01
    DEADBEEF-0000-0000-0000-000000000000,My Budget,Notes for my budget,100,1990/01/01,1990/01/02,My expense 2,,101,1990/01/02
    DEADBEEF-1111-1111-1111-111111111111,My Budget 2,,1,1990/02/01,1990/02/02,,,,
  """
  
  // When I decode the string
  let budgets = try CsvDecoder.decode(csvString)
  
  // Then the decoded budgets are correct
  #expect(budgets.count == 2)
  let budget = try #require(budgets.first(where: { $0.name == "My Budget" }))
  #expect(budget.uuid == UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000000"))
  #expect(budget.notes == "Notes for my budget")
  #expect(budget.startDate.calendarDate == CalendarDate(year: 1990, month: 1, day: 1))
  #expect(budget.endDate.calendarDate == CalendarDate(year: 1990, month: 1, day: 2))
  
  let budget2 = try #require(budgets.first(where: { $0.name == "My Budget 2" }))
  #expect(budget2.uuid == UUID(uuidString: "DEADBEEF-1111-1111-1111-111111111111"))
  #expect(budget2.notes == "")
  #expect(budget2.startDate.calendarDate == CalendarDate(year: 1990, month: 2, day: 1))
  #expect(budget2.endDate.calendarDate == CalendarDate(year: 1990, month: 2, day: 2))
  
  // And the decoded expenses are correct
  let expenses = try #require(budget.expenses)
  #expect(expenses.count == 2)
  
  let expense1 = try #require(expenses.first(where: { $0.name == "My expense 1" }))
  #expect(expense1.notes == "Notes for my expense")
  #expect(expense1.amount == 99)
  #expect(expense1.date.calendarDate == CalendarDate(year: 1990, month: 1, day: 1))
  
  let expense2 = try #require(expenses.first(where: { $0.name == "My expense 2" }))
  #expect(expense2.notes == "")
  #expect(expense2.amount == 101)
  #expect(expense2.date.calendarDate == CalendarDate(year: 1990, month: 1, day: 2))
}
