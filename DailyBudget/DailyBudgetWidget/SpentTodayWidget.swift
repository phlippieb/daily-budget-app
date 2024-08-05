import WidgetKit
import SwiftUI

struct SpentTodayWidget: Widget {
  let kind: String = "SpentTodayWidget"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SelectBudgetIntent.self,
      provider: DailyBudgetWidgetTimelineProvider()) { entry in
        SpentTodayWidgetView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
          .modelContainer(for: [BudgetModel.self, ExpenseModel.self])
      }
      .configurationDisplayName("Spent today")
      .description("Shows the amount spent today for a chosen budget.")
      .supportedFamilies([.systemSmall, .systemMedium])
  }
}

#Preview(as: .systemMedium) {
  SpentTodayWidget()
} timeline: {
  BudgetEntry(date: .now, budgetToDisplay: .noneSelected)
  BudgetEntry(date: .now, budgetToDisplay: .placeholder)
}

// TODO: Fix preview for adding widget