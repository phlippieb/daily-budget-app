// TODO: Use BudgetSummaryViewModel

import SwiftUI
import SwiftData

struct BudgetListItem: View {
  let item: BudgetModel
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  private var viewModel: BudgetSummaryViewModel {
    BudgetProgressInfo(
      budget: item, date: currentDate.value.calendarDate)
    .summaryViewModel
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      // MARK: Day/date
      HStack {
        Image(systemName: "calendar")
        Text(viewModel.dateSummary)
      }
      .font(.footnote)
      .bold()
      .foregroundStyle(.gray)
      
      // MARK: Budget name
      Text(viewModel.name)
        .font(.title2)
        .padding(.vertical, 1)
      
      // MARK: Amount
      Grid(alignment: .topLeading) {
        GridRow {
          Text(viewModel.primaryAmountTitle)
          AmountText(amount: viewModel.primaryAmount)
          // TODO: Green doesn't look so good here
//            .foregroundStyle(viewModel.accentColor)
        }
        
        if let secondaryAmountTitle = viewModel.secondaryAmountTitle, let secondaryAmount = viewModel.secondaryAmount {
          GridRow {
            Text(secondaryAmountTitle)
            AmountText(amount: secondaryAmount)
            // TODO: Consider adding color here
//              .foregroundStyle()
          }
        }
      }
      
      // MARK: Status
      if let status = viewModel.status {
        HStack {
          Image(systemName: "flag")
            .foregroundStyle(.red)
          Text(status)
        }
        .font(.footnote)
        .padding(EdgeInsets(
          top: 2, leading: 0, bottom: 0, trailing: 0))
      }
    }
    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  let items: [BudgetModel] = [
    BudgetModel(
      name: "Current under budget",
      amount: 100,
      firstDay: .today,
      lastDay: .today.adding(days: 1),
      expenses: []),
    
    BudgetModel(
      name: "Current over budget",
      amount: 100,
      firstDay: .today,
      lastDay: .today.adding(days: 1),
      expenses: [
        ExpenseModel(name: "", amount: 200, date: .now)
      ]),
    
    BudgetModel(
      name: "Past under budget",
      amount: 100,
      firstDay: .today.adding(days: -1),
      lastDay: .today.adding(days: -1),
      expenses: [
        ExpenseModel(name: "", amount: 50, date: .now)
      ]),
    
    BudgetModel(
      name: "Past over budget",
      amount: 100,
      firstDay: .today.adding(days: -1),
      lastDay: .today.adding(days: -1),
      expenses: [
        ExpenseModel(name: "", amount: 150, date: .now)
      ]),
    
    BudgetModel(
      name: "Future under budget",
      amount: 100,
      firstDay: .today.adding(days: 1),
      lastDay: .today.adding(days: 1),
      expenses: [
        ExpenseModel(name: "", amount: 50, date: .now)
      ]),
    
    BudgetModel(
      name: "Future over budget",
      amount: 100,
      firstDay: .today.adding(days: 1),
      lastDay: .today.adding(days: 1),
      expenses: [
        ExpenseModel(name: "", amount: 150, date: .now)
      ]),
  ]
  
  items.forEach {
    container.mainContext.insert($0)
  }
  
  return List {
    ForEach(items) { item in
      BudgetListItem(item: item)
    }
  }
  .modelContainer(for: ExpenseModel.self, inMemory: true)
  .environmentObject(CurrentDate())
}
