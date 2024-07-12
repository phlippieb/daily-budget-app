import WidgetKit

struct DailyBudgetWidgetTimelineProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> BudgetEntry {
    .init(date: .now)
  }
  
  func snapshot(
    for configuration: SelectBudgetIntent, 
    in context: Context
  ) async -> BudgetEntry {
    .init(date: .now, entity: configuration.budget)
  }
  
  func timeline(
    for configuration: SelectBudgetIntent, 
    in context: Context
  ) async -> Timeline<BudgetEntry> {
    Timeline(entries: [
      .init(date: .now, entity: configuration.budget)
    ], policy: .never) // TODO: Use policy to refresh data tomorrow
  }
}
