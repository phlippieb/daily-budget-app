import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

/// A simple widget displaying the available amount for a chosen budget
struct DailyBudgetWidget1: Widget {
  let kind: String = "DailyBudgetWidget1"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SelectBudgetIntent.self,
      provider: DailyBudgetWidgetTimelineProvider()) { entry in
        DailyBudgetWidgetView1(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
          .modelContainer(for: BudgetModel.self)
      }
      .configurationDisplayName("Available amount")
      .description("Shows your daily available amount for a chosen budget.")
      .supportedFamilies([.systemSmall, .systemMedium])
  }
}

private struct DailyBudgetWidgetView1: View {
  var entry: BudgetEntry
  
  @Query(sort: \BudgetModel.endDate, order: .reverse) private var budgets: [BudgetModel]
  
  private var info: BudgetProgressInfo? {
    switch entry.budgetToDisplay {
    case .noneSelected:
      guard let budget = budgets.first else { return nil }
      return BudgetProgressInfo(budget: budget, date: .today)
    
    case .placeholder:
      return BudgetProgressInfo(
        budget: BudgetModel(
          name: "My Budget",
          amount: 99.99 * 31,
          firstDay: .today,
          lastDay: .today.adding(days: 30),
          expenses: []),
        date: .today)
      
    case .model(let id):
      guard let budget = budgets.first(where: { $0.uuid == id }) else { return nil }
      return BudgetProgressInfo(budget: budget, date: .today)
    }
  }
  
  var body: some View {
    if let info {
      VStack(alignment: .center) {
        AmountText(
          amount: info.currentAllowance,
          wholePartFont: .system(
            size: UIFont.preferredFont(
              forTextStyle: .largeTitle).pointSize * 2)
        )
        .minimumScaleFactor(0.1)
        .bold()
        .foregroundStyle(.green)
        
        Text("Available today")
          .fontWeight(.light)
        
        Text(info.budget.name)
          .font(.subheadline)
          .bold()
          .lineLimit(2)
          .multilineTextAlignment(.center)
      }
      
    } else {
      Text("No budget selected").foregroundStyle(.gray)
      Text("Long-press to configure")
        .font(.footnote)
    }
  }
}

#Preview(as: .systemMedium) {
  DailyBudgetWidget1()
} timeline: {
  BudgetEntry(date: .now, budgetToDisplay: .noneSelected)
  BudgetEntry(date: .now, budgetToDisplay: .placeholder)
}
