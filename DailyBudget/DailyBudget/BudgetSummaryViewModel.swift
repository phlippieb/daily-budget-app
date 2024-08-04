import SwiftUI

/// Common viewmodel for displaying a summary about a budget
struct BudgetSummaryViewModel {
  let accentColor: Color
  let backgroundAccentColor: Color
  let dateSummary: String
  let isActive: Bool
  let status: String?
  let name: String
  let notes: String
  let primaryAmountTitle: String
  let primaryAmount: Double
  let secondaryAmountTitle: String?
  let secondaryAmount: Double?
  let secondaryAmountOf: Double?
  let tip: BudgetSummaryTipViewModel?
}

enum BudgetSummaryTipViewModel {
  case availableTomorrow(amount: Double)
  case breakEven(days: Int)
  
  var accentColor: Color {
    switch self {
    case .availableTomorrow: return .green
    case .breakEven: return .red
    }
  }
}

extension BudgetProgressInfo {
  var summaryViewModel: BudgetSummaryViewModel {
    self.isActive
    ? activeBudgetSummaryViewModel
    : self.isPast
    ? pastBudgetSummaryViewModel
    : futureBudgetSummaryViewModel
  }
  
  private var activeBudgetSummaryViewModel: BudgetSummaryViewModel {
    .init(
      accentColor: currentAllowance < 0 ? .red : .green,
      backgroundAccentColor: currentAllowance < 0 ? .red : .green,
      dateSummary: "Day \(dayOfBudget) of \(budget.totalDays)",
      isActive: isActive,
      status: budget.totalExpenses > budget.amount
      ? "Total budget exceeded"
      : currentAllowance < 0 ? "Daily amount exceeded" : nil, 
      name: budget.name,
      notes: budget.notes,
      primaryAmountTitle: "Available today",
      primaryAmount: currentAllowance,
      secondaryAmountTitle: "Spent today",
      secondaryAmount: (budget.expenses ?? [])
        .filter { $0.day == date }
        .map(\.amount)
        .reduce(0, +),
      secondaryAmountOf: budget.dailyAmount,
      tip: .init(self)
    )
  }
  
  private var pastBudgetSummaryViewModel: BudgetSummaryViewModel {
    .init(
      accentColor: budget.totalExpenses > budget.amount ? .red : .green,
      backgroundAccentColor: .secondarySystemGroupedBackground,
      dateSummary: "Ended \(budget.lastDay.toStandardFormatting())",
      isActive: isActive,
      status: budget.totalExpenses > budget.amount ? "Total budget exceeded" : nil,
      name: budget.name,
      notes: budget.notes,
      primaryAmountTitle: budget.totalExpenses > budget.amount ? "Over budget by" : "Under budget by",
      primaryAmount: abs(budget.amount - budget.totalExpenses),
      secondaryAmountTitle: "Total spent",
      secondaryAmount: budget.totalExpenses,
      secondaryAmountOf: budget.amount,
      tip: .init(self)
    )
  }
  
  private var futureBudgetSummaryViewModel: BudgetSummaryViewModel {
    .init(
      accentColor: .label,
      backgroundAccentColor: .secondarySystemGroupedBackground,
      dateSummary: "Starts \(budget.firstDay.toStandardFormatting())",
      isActive: isActive,
      status: budget.totalExpenses > budget.amount ? "Total budget exceeded" : nil,
      name: budget.name,
      notes: budget.notes,
      primaryAmountTitle: "Amount",
      primaryAmount: budget.amount,
      secondaryAmountTitle: nil,
      secondaryAmount: nil,
      secondaryAmountOf: nil,
      tip: .init(self)
    )
  }
}

private extension BudgetSummaryTipViewModel {
  init?(_ info: BudgetProgressInfo) {
    let amountAvailableTomorrow = info.currentAllowance + info.budget.dailyAmount
    let daysToBreakEven = -Int(info.currentAllowance / info.budget.dailyAmount) + 1
    
    if
      info.isActive,
      info.date < info.budget.lastDay,
      amountAvailableTomorrow >= 0 {
      self = .availableTomorrow(amount: amountAvailableTomorrow)
      
    } else if
      info.isActive,
      daysToBreakEven > 0,
      info.date.adding(days: daysToBreakEven) <= info.budget.lastDay {
      self = .breakEven(days: daysToBreakEven)
      
    } else {
      return nil
    }
  }
}
