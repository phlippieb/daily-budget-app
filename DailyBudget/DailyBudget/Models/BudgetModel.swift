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
  var startDate: Date
  var endDate: Date
  var expenses: [ExpenseModel]
  
  init(name: String, amount: Double, startDate: Date, endDate: Date, expenses: [ExpenseModel]) {
    self.name = name
    self.amount = amount
    self.startDate = startDate
    self.endDate = endDate
    self.expenses = expenses
  }
}

// MARK: Calendar days -

extension BudgetModel {
  convenience init(name: String, amount: Double, firstDay: CalendarDate, lastDay: CalendarDate, expenses: [ExpenseModel]) {
    self.init(name: name, amount: amount, startDate: firstDay.date, endDate: lastDay.date, expenses: expenses)
  }
  
  var firstDay: CalendarDate {
    get { startDate.calendarDate }
    set { startDate = newValue.date }
  }
  
  var lastDay: CalendarDate {
    get { endDate.calendarDate }
    set { endDate = newValue.date }
  }
}

// MARK: Computed properties -

extension BudgetModel {
  /// Total days is **inclusive** of the last day
  var totalDays: Int {
    (lastDay - firstDay) + 1
  }
  
  var dailyAmount: Double {
    amount / Double(totalDays)
  }
  
  var totalExpenses: Double {
    expenses.reduce(0) { $0 + $1.amount }
  }
}

extension BudgetModel: DefaultInitializable {
  convenience init() {
    self.init(
      name: "", 
      amount: 0,
      startDate: .now,
      endDate: CalendarDate.today.adding(days: 30).date,
      expenses: [])
  }
}
