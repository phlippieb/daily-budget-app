import Foundation

/// # BudgetAtDate model
///
/// Reprents a view of a budget at a specific date.
/// Provides computed info, such as remaining days, current allowance, etc.
struct BudgetAtDate {
  var budget: BudgetModel
  let date: Date
}

extension BudgetAtDate {
  /// Whether `date` falls within `budget`'s start and end dates
  var isActive: Bool {
    budget.startDate <= date && date <= budget.endDate
  }
  
  /// The number of days that `date` falls after `budget`'s start date
  var dayOfBudget: Int {
    date.timeIntervalSince(budget.startDate).toDays()
  }
  
  /// The budget available on `date`
  /// This is computed by comparing the daily allowance (which is budget total / budget duration)
  /// up to `date`, and subtracting all expenses.
  var currentAllowance: Double {
    (budget.dailyAmount * Double(dayOfBudget + 1)) - budget.totalExpenses
  }
}
