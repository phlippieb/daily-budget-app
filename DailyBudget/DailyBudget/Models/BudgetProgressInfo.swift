import Foundation

/// # BudgetProgressInfo model
///
/// Info about a budget at a specific date.
/// Provides computed info, such as remaining days, current allowance, etc.
struct BudgetProgressInfo {
  var budget: BudgetModel
  let date: CalendarDate
}

extension BudgetProgressInfo {
  /// Whether `date` falls within `budget`'s start and end dates
  var isActive: Bool {
    budget.startDate <= date && date <= budget.endDate
  }
  
  /// The number of days that `date` falls after `budget`'s start date
  /// - NOTE: Starts at 1
  var dayOfBudget: Int {
    (date - budget.startDate) + 1
  }
  
  /// The budget available on `date`
  /// This is computed by comparing the daily allowance (which is budget total / budget duration)
  /// up to `date`, and subtracting all expenses.
  var currentAllowance: Double {
    (budget.dailyAmount * Double(dayOfBudget)) - budget.totalExpenses
  }
}
