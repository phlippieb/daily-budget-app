import Foundation
import SwiftData

/// # Budget model
///
/// SwiftData-backed model for a budget.
/// An instance represents a purpose-specific, time-ranged budget and its associated expenses.
/// This model is ignorant of the current date vis-a-vis the budget's date; see BudetAtDate
@Model final class BudgetModel {
  var name: String
  var amount: Double
  
  var startDate: CalendarDate {
    get { CalendarDate(date: _startDate) }
    set { _startDate = newValue.date }
  }
  
  var endDate: CalendarDate {
    get { CalendarDate(date: _endDate) }
    set { _endDate = newValue.date }
  }
  
  var expenses: [ExpenseModel]
  
  private var _startDate: Date
  private var _endDate: Date
  
  init(name: String, amount: Double, startDate: CalendarDate, endDate: CalendarDate, expenses: [ExpenseModel]) {
    self.name = name
    self.amount = amount
    self._startDate = startDate.date
    self._endDate = endDate.date
    self.expenses = expenses
  }
}

// MARK: Computed properties -

extension BudgetModel {
  /// Total days is **inclusive** of the last day
  var totalDays: Int {
    (endDate - startDate) + 1
  }
  
  var dailyAmount: Double {
    amount / Double(totalDays)
  }
  
  var totalExpenses: Double {
    expenses.reduce(0) { $0 + $1.amount }
  }
  
  /// A valid date range for expenses
  var dateRange: ClosedRange<Date> {
    return startDate.date ... endDate.date
  }
}

extension BudgetModel: DefaultInitializable {
  convenience init() {
    self.init(
      name: "", 
      amount: 0,
      startDate: .today,
      endDate: .today.adding(days: 30),
      expenses: [])
  }
}
