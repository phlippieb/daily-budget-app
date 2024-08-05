import WidgetKit
import SwiftUI

/// A simple widget displaying the available amount for a chosen budget
struct AvailableTodayWidget: Widget {
  let kind: String = "DailyBudgetWidget1"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SelectBudgetIntent.self,
      provider: DailyBudgetWidgetTimelineProvider()) { entry in
        AvailableTodayWidgetView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
          .modelContainer(for: BudgetModel.self)
      }
      .configurationDisplayName("Available amount")
      .description("Shows your daily available amount for a chosen budget.")
      .supportedFamilies([.systemSmall, .systemMedium])
  }
}

#Preview(as: .systemMedium) {
  AvailableTodayWidget()
} timeline: {
  BudgetEntry(date: .now, budgetToDisplay: .noneSelected)
  BudgetEntry(date: .now, budgetToDisplay: .placeholder)
}
