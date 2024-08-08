struct ViewModelProvider {
  let displayedBudget: BudgetEntry.DisplayedBudget
  var budgets: () -> [BudgetModel]
  
  var viewModel: BudgetSummaryViewModel? {
    switch displayedBudget {
    case .noneSelected:
      // NOTE: User *has* to choose a budget, otherwise tap action has
      // unexpected consequences.
      return nil
    case .placeholder:
      return .placeholder
    case .model(let id):
      guard let budget = budgets().first(where: { $0.uuid == id }) else { return nil }
      return BudgetProgressInfo(budget: budget, date: .today).summaryViewModel
    }
  }
}

private extension BudgetSummaryViewModel {
  static let placeholder = BudgetSummaryViewModel(
    accentColor: .green,
    backgroundAccentColor: .green,
    dateSummary: "Day 1 of 30",
    isActive: true,
    status: nil,
    name: "My Budget",
    notes: "",
    primaryAmountTitle: "Available today",
    primaryAmount: 199,
    secondaryAmountTitle: "Spent today",
    secondaryAmount: 21,
    secondaryAmountOf: 220,
    tip: nil)
}
