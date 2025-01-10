import Testing
import Foundation
import SwiftCSV

@testable import DailyBudget

@Test func testImportCsvWithMultipleTransactions() throws {
  // Given some CSV data with one budget with two expenses
  let csvString = """
    budgetUUID,budgetName,budgetNotes,budgetAmount,budgetFirstDay,budgetLastDay,expenseName,expenseNotes,expenseAmount,expenseDate
    DEADBEEF-0000-0000-0000-000000000000,My Budget,Notes for my budget,100,1990/01/01,1990/01/02,My expense 1,Notes for my expense,99,1990/01/01
    DEADBEEF-0000-0000-0000-000000000000,My Budget,Notes for my budget,100,1990/01/01,1990/01/02,My expense 2,,101,1990/01/02
  """
  
  // When I decode the string
  let budgets = try CsvDecoder().decode(csvString)
  
  // Then the decoded budget is correct
  #expect(budgets.count == 1)
  let budget = try #require(budgets.first)
  #expect(budget.uuid == UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000000"))
  #expect(budget.name == "My Budget")
  #expect(budget.notes == "Notes for my budget")
  #expect(budget.startDate.calendarDate == CalendarDate(year: 1990, month: 1, day: 1))
  #expect(budget.endDate.calendarDate == CalendarDate(year: 1990, month: 1, day: 2))
  
  // And the decoded expenses are correct
  let expenses = try #require(budget.expenses)
  #expect(expenses.count == 2)
  let expense1 = try #require(expenses.first(where: { $0.name == "My expense 1" }))
  let expense2 = try #require(expenses.first(where: { $0.name == "My expense 2" }))
  
  #expect(expense1.name == "My expense 1")
  #expect(expense1.notes == "Notes for my expense")
  #expect(expense1.amount == 99)
  #expect(expense1.date.calendarDate == CalendarDate(year: 1990, month: 1, day: 1))
  
  #expect(expense2.name == "My expense 2")
  #expect(expense2.notes == "")
  #expect(expense2.amount == 101)
  #expect(expense2.date.calendarDate == CalendarDate(year: 1990, month: 1, day: 2))
}

// MARK: - Solution
// TODO: Refactor

// TODO: This class is stateless. Make it a namespace + static method instead?
class CsvDecoder {
  /// - NOTE: Case names correspond to expected values in the raw CSV Strings. Do not edit them.
  enum Keys: String {
    case budgetUUID, budgetName, budgetNotes, budgetAmount, budgetFirstDay,
         budgetLastDay, expenseName, expenseNotes, expenseAmount, expenseDate
  }
  
  enum DecodingError: Error {
    /// All required headers must have data
    case missingData(row: [String: String])
    
    /// If a non-empty transaction name is provided, all transaction data (except note) must be non-empty
    case incompleteTransactionData(row: [String: String])
    
    /// Data is formatted incorrectly for the indicated key
    case invalidData(_: String, for: Keys, comment: String)
  }
  
  func decode(_ string: String) throws -> [BudgetModel] {
    var results: [UUID: BudgetModel] = [:]
    
    // Cleanup commented lines and leading/trailling whitespace
    let string = string
      .components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { $0.first != "#" }
      .joined(separator: "\n") // Recombine into one string
    
    let csv = try CSV<Named>(string: string)
    
    try csv.rows.forEach { row in
      guard
        let budgetUuidString = row[.budgetUUID],
        let budgetName = row[.budgetName],
        let budgetNotes = row[.budgetNotes],
        let budgetAmountString = row[.budgetAmount],
        let budgetFirstDayString = row[.budgetFirstDay],
        let budgetLastDayString = row[.budgetLastDay]
      else {
        throw DecodingError.missingData(row: row)
      }
      
      guard let budgetUuid = UUID(uuidString: budgetUuidString) else {
        throw DecodingError.invalidData(
          budgetUuidString,
          for: .budgetUUID,
          comment: "budgetUUID should be a valid UUID")
      }
      
      guard let budgetAmount = Double(budgetAmountString) else {
        throw DecodingError.invalidData(
          budgetAmountString,
          for: .budgetAmount,
          comment: "budgetAmount should be a valid Double-representable number"
        )
      }
      
      let budgetFirstDay = try decodeCalendarDate(from: budgetFirstDayString)
      let budgetLastDay = try decodeCalendarDate(from: budgetLastDayString)
      
      let budget = results[budgetUuid] ?? .init(
        uuid: budgetUuid,
        name: budgetName,
        notes: budgetNotes,
        amount: budgetAmount,
        firstDay: budgetFirstDay,
        lastDay: budgetLastDay,
        expenses: [])
            
      // NOTE: Expense data is optional; a budget may have 0 expenses.
      // HOWEVER: If data is present, it must be valid.
      if let expenseName = row[.expenseName]?.nonEmpty {
        guard
          let expenseNotes = row[.expenseNotes], // May be empty
          let expenseAmountString = row[.expenseAmount]?.nonEmpty,
          let expenseAmount = Double(expenseAmountString),
          let expenseDateString = row[.expenseDate]?.nonEmpty
        else {
          throw DecodingError.incompleteTransactionData(row: row)
        }
        
        let expenseDay = try decodeCalendarDate(from: expenseDateString)
        let expense = ExpenseModel(
          name: expenseName,
          notes: expenseNotes,
          amount: expenseAmount,
          day: expenseDay)
        budget.expenses?.append(expense)
      }
      
      results[budgetUuid] = budget
    }
    
    return results.map { $1 }
  }
  
  private func decodeCalendarDate(from string: String) throws -> CalendarDate {
    let components = string.split(separator: "/")
    guard
      components.count == 3,
      let y = Int(components[0]),
      let m = Int(components[1]),
      let d = Int(components[2])
    else {
      throw DecodingError.invalidData(
        string,
        for: .budgetLastDay,
        comment: "Date should be formatted as yyyy/mm/dd"
      )
    }
    
    return CalendarDate(year: y, month: m, day: d)
  }
}

private extension Dictionary<String, String> {
  subscript(key: CsvDecoder.Keys) -> String? {
    self[key.rawValue]
  }
}

extension Collection {
  var nonEmpty: Self? {
    self.count == 0 ? nil : self
  }
}
