import SwiftUI

/// # BudgetProgressInfo model
///
/// Info about a budget at a specific date.
/// Provides computed info, such as remaining days, current allowance, etc.
struct BudgetProgressInfo {
  var budget: BudgetModel
  let date: CalendarDate
}

// MARK: Computed -

extension BudgetProgressInfo {
  /// Whether `date` falls within `budget`'s start and end dates
  var isActive: Bool {
    budget.firstDay <= date && date <= budget.lastDay
  }
  
  var isPast: Bool {
    budget.lastDay < date
  }
  
  /// The number of days that `date` falls after `budget`'s start date
  /// - NOTE: Starts at 1
  var dayOfBudget: Int {
    date - budget.firstDay + 1
  }
  
  /// The budget available on `date`
  /// This is computed by comparing the daily allowance (which is budget total / budget duration)
  /// up to `date`, and subtracting all expenses.
  var currentAllowance: Double {
    (budget.dailyAmount * Double(dayOfBudget)) - budget.totalExpenses
  }
}
