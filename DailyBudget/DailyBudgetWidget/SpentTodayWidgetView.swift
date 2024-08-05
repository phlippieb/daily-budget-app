import SwiftUI
import SwiftData

struct SpentTodayWidgetView: View {
  var entry: BudgetEntry
  
  @Query(sort: \BudgetModel.endDate, order: .reverse) private var budgets: [BudgetModel]
  
  @Environment(\.modelContext) private var context
  
  private var info: BudgetProgressInfo? {
    switch entry.budgetToDisplay {
    case .noneSelected:
      guard let budget = budgets.first else { return nil }
      return BudgetProgressInfo(budget: budget, date: .today)
      
    case .placeholder:
      return BudgetProgressInfo(
        budget: BudgetModel(
          name: "My Budget",
          notes: "",
          amount: 99.99 * 31,
          firstDay: .today,
          lastDay: .today.adding(days: 30),
          expenses: [
            ExpenseModel(name: "", notes: "", amount: 42, date: .now)
          ]),
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
      if let secondaryAmount = viewModel.secondaryAmount {
        VStack(alignment: .center) {
          AmountText(
            amount: secondaryAmount,
            wholePartFont: .system(
              size: UIFont.preferredFont(
                forTextStyle: .largeTitle).pointSize * 2)
          )
          .minimumScaleFactor(0.1)
          .bold()
          
          Text("Spent today")
            .fontWeight(.light)
          
          Text(viewModel.name)
            .font(.subheadline)
            .bold()
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }
      } else {
        Text("TODO: spent today not applicable")
      }
      
    } else {
      Text("No budget selected").foregroundStyle(.gray)
      Text("Long-press to configure")
        .font(.footnote)
    }
  }
}

