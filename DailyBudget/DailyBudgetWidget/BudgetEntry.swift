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
