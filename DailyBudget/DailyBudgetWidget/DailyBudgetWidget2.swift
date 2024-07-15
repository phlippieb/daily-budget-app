import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

/// A simple widget displaying the available amount for a chosen budget
struct DailyBudgetWidget2: Widget {
  let kind: String = "DailyBudgetWidget2"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SelectBudgetIntent.self,
      provider: DailyBudgetWidgetTimelineProvider()) { entry in
        DailyBudgetWidgetView2(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
          .modelContainer(for: BudgetModel.self)
      }
      .configurationDisplayName("Available and spent amount")
      .description("Shows your daily available amount for a chosen budget, along with the amount spent.")
      .supportedFamilies([.systemMedium])
  }
}

private struct DailyBudgetWidgetView2: View {
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
  
  private var viewModel: BudgetSummaryViewModel? {
    info?.summaryViewModel
  }
  
  var body: some View {
    if let viewModel {
      VStack {
        HStack {
          Text(viewModel.name)
            .font(.subheadline)
            .bold()
            .lineLimit(2)
            .multilineTextAlignment(.center)
          Spacer()
          Image(systemName: "calendar")
          Text(viewModel.dateSummary)
        }
        .font(.footnote)
        
        Spacer()
        
        Grid {
          GridRow(alignment: .lastTextBaseline) {
            AmountText(
              amount: viewModel.primaryAmount,
              wholePartFont: .system(
                size: UIFont.preferredFont(
                  forTextStyle: .largeTitle).pointSize * 2)
            )
            .minimumScaleFactor(0.1)
            .bold()
            .foregroundStyle(.green)
            
            if let secondaryAmount = viewModel.secondaryAmount {
              Text("")
              AmountText(
                amount: secondaryAmount,
                wholePartFont: .system(
                  size: UIFont.preferredFont(
                    forTextStyle: .largeTitle).pointSize)
              )
              .minimumScaleFactor(0.1)
              .bold()
            }
          }
          
          GridRow(alignment: .lastTextBaseline) {
            Text(viewModel.primaryAmountTitle)
              .fontWeight(.light)
            
            if let secondaryAmountTitle = viewModel.secondaryAmountTitle {
              Text("")
              Text(secondaryAmountTitle)
                .fontWeight(.light)
            }
          }
        }
      }
      
    } else {
      Text("No budget selected").foregroundStyle(.gray)
      Text("Long-press to configure")
        .font(.footnote)
    }
  }
}

#Preview(as: .systemMedium) {
  DailyBudgetWidget2()
} timeline: {
  BudgetEntry(date: .now, budgetToDisplay: .noneSelected)
  BudgetEntry(date: .now, budgetToDisplay: .placeholder)
}
