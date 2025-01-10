import Foundation
import SwiftCSV

enum CsvDecoder {
  enum DecodingError: Error {
    /// All required headers must have data
    case missingData(row: [String: String])
    
    /// If a non-empty transaction name is provided, all transaction data (except note) must be non-empty
    case incompleteTransactionData(row: [String: String])
    
    /// Data is formatted incorrectly for the indicated key
    case invalidData(_: String, forKey: String, comment: String)
  }
  
  static func decode(_ string: String) throws -> [BudgetModel] {
    var results: [UUID: BudgetModel] = [:]
    
    // Cleanup commented lines and leading/trailling whitespace
    let string = string
      .components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { $0.first != "#" }
      .joined(separator: "\n")
    
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
          forKey: CsvKey.budgetUUID.rawValue,
          comment: "budgetUUID should be a valid UUID")
      }
      
      guard let budgetAmount = Double(budgetAmountString) else {
        throw DecodingError.invalidData(
          budgetAmountString,
          forKey: CsvKey.budgetAmount.rawValue,
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
  
  private static func decodeCalendarDate(from string: String) throws -> CalendarDate {
    let components = string.split(separator: "/")
    guard
      components.count == 3,
      let y = Int(components[0]),
      let m = Int(components[1]),
      let d = Int(components[2])
    else {
      throw DecodingError.invalidData(
        string,
        forKey: CsvKey.budgetLastDay.rawValue,
        comment: "Date should be formatted as yyyy/mm/dd"
      )
    }
    
    return CalendarDate(year: y, month: m, day: d)
  }
}

private extension Dictionary<String, String> {
  subscript(key: CsvKey) -> String? {
    self[key.rawValue]
  }
}

/// - NOTE: Case names correspond to expected values in the raw CSV Strings. Do not edit them.
private enum CsvKey: String {
  case budgetUUID, budgetName, budgetNotes, budgetAmount, budgetFirstDay,
       budgetLastDay, expenseName, expenseNotes, expenseAmount, expenseDate
}
