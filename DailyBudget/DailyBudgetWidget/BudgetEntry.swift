import WidgetKit

struct BudgetEntry: TimelineEntry {
  var date: Date
  
  enum DisplayedBudget {
    case noneSelected
    case placeholder
    case model(id: UUID)
  }
  
  /// The selected budget's entity representation, if one is selected
  var budgetToDisplay: DisplayedBudget
}

extension BudgetSummaryViewModel {
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
