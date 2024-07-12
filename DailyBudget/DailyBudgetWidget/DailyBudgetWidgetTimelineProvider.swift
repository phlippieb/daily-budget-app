import WidgetKit

struct DailyBudgetWidgetTimelineProvider: AppIntentTimelineProvider {
  /// Note: This is called in the gallery. Need a way to show a preview without a real backing budget!
  func placeholder(in context: Context) -> BudgetEntry {
    .init(date: .now)
  }
  
  func snapshot(
    for configuration: SelectBudgetIntent, 
    in context: Context
  ) async -> BudgetEntry {
    // Then this is called when actually viewing the gallery
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
