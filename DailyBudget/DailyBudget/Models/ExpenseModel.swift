import Foundation
import SwiftData

/// # Expense model
///
/// SwiftData-backed model for an expense.
/// An instance represents a single expense associated with a budget.
@Model final class ExpenseModel {
  
  var name: String
  var amount: Double
  
  var date: CalendarDate {
    get { CalendarDate(date: __date) }
    set { __date = newValue.date }
  }
  
  private var __date: Date
  
  init(name: String, amount: Double, date: CalendarDate) {
    self.name = name
    self.amount = amount
    self.__date = date.date
  }
}

extension ExpenseModel: DefaultInitializable {
  convenience init() {
    self.init(name: "", amount: 0, date: .today)
  }
}
