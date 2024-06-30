import Foundation
import SwiftData

/// # Expense model
///
/// SwiftData-backed model for an expense.
/// An instance represents a single expense associated with a budget.
@Model final class ExpenseModel {
  
  var name: String = ""
  var amount: Double = 0
  var date: Date = Date()
  
  @Relationship var budget: BudgetModel? = nil
  
  init(name: String, amount: Double, date: Date) {
    self.name = name
    self.amount = amount
    self.date = date
  }
}

// MARK: Calendar days -

extension ExpenseModel {
  convenience init(name: String, amount: Double, day: CalendarDate) {
    self.init(name: name, amount: amount, date: day.date)
  }
  
  var day: CalendarDate {
    get { date.calendarDate }
    set { date = newValue.date }
  }
}

extension ExpenseModel: DefaultInitializable, UnitProvider {
  convenience init() {
    self.init(name: "", amount: 0, day: .today)
  }
  
  static let unit = ExpenseModel()
}
