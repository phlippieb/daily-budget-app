import Foundation
import SwiftData

/// # Expense model
///
/// SwiftData-backed model for an expense.
/// An instance represents a single expense associated with a budget.
@Model final class ExpenseModel {
  
  @Attribute(.allowsCloudEncryption) var name: String = ""
  @Attribute(.allowsCloudEncryption) var notes: String = ""
  @Attribute(.allowsCloudEncryption) var amount: Double = 0
  @Attribute(.allowsCloudEncryption) var date: Date = Date()
  
  @Relationship var budget: BudgetModel? = nil
  
  convenience init() {
    self.init(name: "", notes: "", amount: 0, day: .today)
  }
  
  init(name: String, notes: String, amount: Double, date: Date) {
    self.name = name
    self.notes = notes
    self.amount = amount
    self.date = date
  }
}

// MARK: Calendar days -

extension ExpenseModel {
  convenience init(name: String, notes: String, amount: Double, day: CalendarDate) {
    self.init(name: name, notes: notes, amount: amount, date: day.date)
  }
  
  var day: CalendarDate {
    get { date.calendarDate }
    set { date = newValue.date }
  }
}

extension ExpenseModel: UnitProviding {
  static let unit = ExpenseModel()
}
