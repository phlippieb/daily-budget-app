import SwiftUI
import SwiftData

struct AvailableAndSpentTodayWidgetView: View {
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
          notes: "",
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
            .foregroundStyle(viewModel.accentColor)
            
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
