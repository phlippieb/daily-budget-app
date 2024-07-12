import WidgetKit

struct DailyBudgetWidgetTimelineProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> BudgetEntry {
    .init(date: .now, budgetToDisplay: .placeholder)
  }
  
  func snapshot(
    for configuration: SelectBudgetIntent, 
    in context: Context
  ) async -> BudgetEntry {
    .init(date: .now, budgetToDisplay: .placeholder)
  }
  
  func timeline(
    for configuration: SelectBudgetIntent, 
    in context: Context
  ) async -> Timeline<BudgetEntry> {
    Timeline(entries: [
      .forEntity(configuration.budget)
    ], policy: .never) // TODO: Use policy to refresh data tomorrow
  }
}

private extension BudgetEntry {
  static func forEntity(_ entityOrNil: BudgetEntity?) -> Self {
    .init(date: .now, budgetToDisplay: .forEntity(entityOrNil))
  }
}

private extension BudgetEntry.DisplayedBudget {
  static func forEntity(_ entityOrNil: BudgetEntity?) -> Self {
    switch entityOrNil {
    case .some(let entity): return .model(id: entity.id)
    case .none: return .noneSelected
    }
  }
}
