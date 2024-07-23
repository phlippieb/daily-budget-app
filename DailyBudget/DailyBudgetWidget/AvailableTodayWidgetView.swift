import SwiftUI
import SwiftData

struct AvailableTodayWidgetView: View {
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
        .foregroundStyle(info.currentAllowance < 0 ? .red : .green)
        
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
