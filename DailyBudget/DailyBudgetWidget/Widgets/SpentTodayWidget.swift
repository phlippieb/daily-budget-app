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
          .widgetURL(NavigationObject.viewingBudgetUrl(uuid: entry.id))
      }
      .configurationDisplayName("Spent today")
      .description("Shows the amount spent for a chosen budget.")
      .supportedFamilies([.systemSmall, .systemMedium])
  }
}

#Preview(as: .systemMedium) {
  SpentTodayWidget()
} timeline: {
  BudgetEntry(date: .now, budgetToDisplay: .noneSelected)
  BudgetEntry(date: .now, budgetToDisplay: .placeholder)
}
