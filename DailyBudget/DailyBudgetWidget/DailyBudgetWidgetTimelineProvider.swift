import WidgetKit

struct DailyBudgetWidgetTimelineProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> BudgetEntry {
    .init(date: .now, details: .init(title: "TODO", dateText: "TODO", available: 0, spent: 0))
  }
  
  func snapshot(for configuration: SelectBudgetIntent, in context: Context) async -> BudgetEntry {
    .init(date: .now, details: .init(title: "TODO", dateText: "TODO", available: 0, spent: 0))
  }
  
  func timeline(
    for configuration: SelectBudgetIntent,
    in context: Context
  ) async -> Timeline<BudgetEntry> {
    Timeline(entries: [BudgetEntry(
      date: .now, details: .init(entity: configuration.budget))
    ], policy: .never)
  }
}

private extension BudgetEntryDetails {
  init(entity: BudgetEntity) {
    // TODO: Include all info in entity, apparently, OR
    // TODO: Include ONLY id in entry, and use swiftdata to fetch
    self.init(title: entity.name, dateText: "TODO", available: 0, spent: 0)
  }
}

// MARK: Using entity as entry

struct DailyBudgetWidgetTimelineProvider2: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> BudgetEntity {
    .init(id: .init(), name: "TODO")
  }
  
  func snapshot(for configuration: SelectBudgetIntent, in context: Context) async -> BudgetEntity {
    .init(id: .init(), name: "TODO")
  }
  
  func timeline(for configuration: SelectBudgetIntent, in context: Context) async -> Timeline<BudgetEntity> {
    Timeline(entries: [configuration.budget], policy: .never)
  }
}

extension BudgetEntity: TimelineEntry {
  var date: Date {
    .now
  }
}
