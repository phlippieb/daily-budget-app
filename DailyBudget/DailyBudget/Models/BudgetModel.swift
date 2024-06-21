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

// MARK: Computed properties -

extension BudgetModel {
  var totalDays: Int {
    endDate.timeIntervalSince(startDate).toDays()
  }
  
  var dailyAmount: Double {
    amount / Double(totalDays)
  }
  
  var totalExpenses: Double {
    expenses.reduce(0) { $0 + $1.amount }
  }
  
  /// A valid date range for expenses
  var dateRange: ClosedRange<Date> {
    return startDate ... endDate
  }
}

extension BudgetModel: DefaultInitializable {
  convenience init() {
    self.init(
      name: "", amount: 0, startDate: .now,
      endDate: .now.addingTimeInterval(.oneDay), expenses: [])
  }
}
