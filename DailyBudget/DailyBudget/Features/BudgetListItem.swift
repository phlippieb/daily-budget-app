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
      .bold(!viewModel.isActive)
      .foregroundStyle(viewModel.isActive ? Color.label : .gray)
      
      // MARK: Budget name
      Text(viewModel.name)
        .font(.title2)
        .padding(.vertical, 1)
      
      // MARK: Notes
      if !viewModel.notes.isEmpty {
        Text(viewModel.notes)
          .foregroundStyle(.secondary)
          .padding(.vertical, 1)
      }
      
      // MARK: Amount
      Grid(alignment: .topLeading) {
        GridRow {
          Text(viewModel.primaryAmountTitle)
          AmountText(amount: viewModel.primaryAmount)
        }
        
        if let secondaryAmountTitle = viewModel.secondaryAmountTitle, let secondaryAmount = viewModel.secondaryAmount {
          GridRow {
            Text(secondaryAmountTitle)
            AmountText(amount: secondaryAmount)
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
    
    .listRowBackground(
      LinearGradient(
        stops: [
          .init(color: .secondarySystemGroupedBackground, location: 0.4),
          .init(color: viewModel.backgroundAccentColor.opacity(0.1), location: 1),
        ],
        startPoint: UnitPoint.topLeading, endPoint: .bottomTrailing
      )
      .background(Color.secondarySystemGroupedBackground)
    )
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  let items: [BudgetModel] = [
    BudgetModel(
      name: "Current under budget",
      notes: "Example of a budget that is active and under budget",
      amount: 100,
      firstDay: .today,
      lastDay: .today.adding(days: 1),
      expenses: []),
    
    BudgetModel(
      name: "Current over budget",
      notes: "Example of an active budget where the daily amount has been exceeded",
      amount: 100,
      firstDay: .today,
      lastDay: .today.adding(days: 1),
      expenses: [
        ExpenseModel(name: "", notes: "", amount: 200, date: .now)
      ]),
    
    BudgetModel(
      name: "Past under budget",
      notes: "",
      amount: 100,
      firstDay: .today.adding(days: -1),
      lastDay: .today.adding(days: -1),
      expenses: [
        ExpenseModel(name: "", notes: "", amount: 50, date: .now)
      ]),
    
    BudgetModel(
      name: "Past over budget",
      notes: "",
      amount: 100,
      firstDay: .today.adding(days: -1),
      lastDay: .today.adding(days: -1),
      expenses: [
        ExpenseModel(name: "", notes: "", amount: 150, date: .now)
      ]),
    
    BudgetModel(
      name: "Future under budget",
      notes: "",
      amount: 100,
      firstDay: .today.adding(days: 1),
      lastDay: .today.adding(days: 1),
      expenses: [
        ExpenseModel(name: "", notes: "", amount: 50, date: .now)
      ]),
    
    BudgetModel(
      name: "Future over budget",
      notes: "",
      amount: 100,
      firstDay: .today.adding(days: 1),
      lastDay: .today.adding(days: 1),
      expenses: [
        ExpenseModel(name: "", notes: "", amount: 150, date: .now)
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
