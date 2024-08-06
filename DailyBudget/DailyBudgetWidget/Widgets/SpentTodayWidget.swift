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
          .widgetURL(
            entry.id.unwrapped { id in
              AppUrl.viewBudget(uuid: id.uuidString).url
            }
          )
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

// TODO: Move to extension

extension Optional {
  func unwrapped<T>(in closure: (Wrapped) -> T?) -> T? {
    switch self {
    case .some(let wrapped): return closure(wrapped)
    case .none: return nil
    }
  }
}
