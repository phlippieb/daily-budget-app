import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

/// A simple widget displaying the available amount for a chosen budget
struct AvailableAndSpentTodayWidget: Widget {
  let kind: String = "DailyBudgetWidget2"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SelectBudgetIntent.self,
      provider: DailyBudgetWidgetTimelineProvider()) { entry in
        AvailableAndSpentTodayWidgetView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
          .modelContainer(for: BudgetModel.self)
          .widgetURL(NavigationObject.viewingBudgetUrl(uuid: entry.id))
      }
      .configurationDisplayName("Available and spent today")
      .description("Shows your daily available amount for a chosen budget, along with the amount spent.")
      .supportedFamilies([.systemMedium])
  }
}

#Preview(as: .systemMedium) {
  AvailableAndSpentTodayWidget()
} timeline: {
  BudgetEntry(date: .now, budgetToDisplay: .noneSelected)
  BudgetEntry(date: .now, budgetToDisplay: .placeholder)
}
