import SwiftUI
import SwiftData

struct AvailableTodayWidgetView: View {
  var entry: BudgetEntry
  
  @Query(sort: \BudgetModel.endDate, order: .reverse) private var budgets: [BudgetModel]
  
  private var viewModel: BudgetSummaryViewModel? {
    switch entry.budgetToDisplay {
    case .noneSelected:
      guard let budget = budgets.first else { return nil }
      return BudgetProgressInfo(budget: budget, date: .today).summaryViewModel
    case .placeholder:
      return .placeholder
    case .model(let id):
      guard let budget = budgets.first(where: { $0.uuid == id }) else { return nil }
      return BudgetProgressInfo(budget: budget, date: .today).summaryViewModel
    }
  }
  
  var body: some View {
    if let viewModel {
      VStack(alignment: .center) {
        AmountText(
          amount: viewModel.primaryAmount,
          wholePartFont: .system(
            size: UIFont.preferredFont(
              forTextStyle: .largeTitle).pointSize * 2)
        )
        .minimumScaleFactor(0.1)
        .bold()
        .foregroundStyle(viewModel.accentColor)
        
        Text(viewModel.primaryAmountTitle)
          .fontWeight(.light)
        
        Text(viewModel.name)
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
