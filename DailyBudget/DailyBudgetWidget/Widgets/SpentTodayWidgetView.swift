import SwiftUI
import SwiftData

struct SpentTodayWidgetView: View {
  var entry: BudgetEntry
  
  @Query(sort: \BudgetModel.endDate, order: .reverse) private var budgets: [BudgetModel]
  
  @Environment(\.modelContext) private var context
  
  private var viewModel: BudgetSummaryViewModel? {
    ViewModelProvider(
      displayedBudget: entry.budgetToDisplay, budgets: { budgets }
    ).viewModel
  }
  
  var body: some View {
    if let viewModel, let secondaryAmount = viewModel.secondaryAmount {
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
      Text("Select an active budget").foregroundStyle(.gray)
      Text("Long-press to configure")
        .font(.footnote)
    }
  }
}
