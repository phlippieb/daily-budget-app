import SwiftUI
import SwiftData

struct ViewBudget: View {
  @State var budget: BudgetModel
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  @State private var editingBudget: BudgetModel??
  @State private var editingExpense: ExpenseModel??
  
  private var info: BudgetProgressInfo {
    .init(budget: budget, date: currentDate.value.calendarDate)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.0) { (title, content) in
        Section(title) { content }
          .headerProminence(.increased)
      }
    }
    .navigationTitle(info.budget.name)
    .navigationBarTitleDisplayMode(.inline)
    
    .sheet(item: $editingBudget, content: { _ in
      EditBudget(budget: $editingBudget)
    })
    
    .sheet(item: $editingExpense) { expense in
      EditExpense(
        expense: $editingExpense,
        associatedBudget: info.budget)
    }
  }
  
  private typealias ViewBudgetSection = (
    title: String, body: AnyView)
  
  private var sections: [ViewBudgetSection] { [
    (
      title: info.isActive ? "Today" : "Summary",
      body: .init(TodaySummary(viewModel: info.summaryViewModel))
    ), (
      title: "Budget info",
      body: .init(BudgetInfo(budget: budget, editingBudget: $editingBudget))
    ), (
      title: "Recent expenses",
      body: .init(RecentExpenses(
        budget: $budget,
        editingExpense: $editingExpense))
    )
  ] }
}

// MARK: Summary section -
// For active budgets: today's amount; total spent amount
// For past budgets: over/under budget amount; total spent amount
// For future budgets: amount
private struct TodaySummary: View {
  let viewModel: BudgetSummaryViewModel
  
  var body: some View {
    VStack(alignment: .leading) {
      // MARK: Date and status
      HStack {
        Image(systemName: "calendar")
          .foregroundStyle(viewModel.isActive ? Color.label : .gray)
        Text(viewModel.dateSummary)
        
        if let status = viewModel.status {
          Spacer()
          Image(systemName: "flag")
            .foregroundStyle(.red)
          Text(status)
        }
      }
      .font(.subheadline)
      
      // MARK: Primary amount
      Text("")
      Text(viewModel.primaryAmountTitle).font(.headline)
      AmountText(amount: viewModel.primaryAmount, wholePartFont: .largeTitle)
        .bold()
        .foregroundStyle(viewModel.accentColor)
      
      // MARK: Secondary amount
      if let secondaryAmountTitle = viewModel.secondaryAmountTitle, let secondaryAmount = viewModel.secondaryAmount {
        Divider()
        Text("")
        Text(secondaryAmountTitle).font(.subheadline).bold()
        HStack(spacing: 0) {
          AmountText(amount: secondaryAmount).bold()
          
          if let secondaryAmountOf = viewModel.secondaryAmountOf {
            Text(" of ")
            AmountText(amount: secondaryAmountOf)
          }
        }
      }
    }
    
    .listRowBackground(
      LinearGradient(
        stops: [
          .init(color: .secondarySystemGroupedBackground, location: 0.4),
          .init(color: viewModel.backgroundAccentColor.opacity(0.15), location: 1),
        ],
        startPoint: UnitPoint.topLeading, endPoint: .bottomTrailing
      )
      .background(Color.secondarySystemGroupedBackground)
    )
  }
}

// MARK: Budget info section -

private struct BudgetInfo: View {
  let budget: BudgetModel
  @Binding var editingBudget: BudgetModel??
  
  var body: some View {
    Button(action: onEditBudgetTapped) {
      HStack {
        Text("Edit")
        Spacer()
        Image(systemName: "pencil.line")
      }
    }
    
    ForEach(items, id: \.0) { (title, content) in
      LabeledContent(title, content: { content })
    }
  }
  
  private var items: [(String, AnyView)] {
    [
      ("Period", .init(HStack(spacing: 0) {
        Text(budget.firstDay.toStandardFormatting())
        if budget.firstDay != budget.lastDay {
          Text(" to " + budget.lastDay.toStandardFormatting())
        }
      })),
      ("Total budget", .init(AmountText(amount: budget.amount))),
      ("Total spent", .init(AmountText(amount: budget.totalExpenses))),
      ("Daily amount", .init(AmountText(amount: budget.dailyAmount)))
    ]
  }
  
  private func onEditBudgetTapped() {
    editingBudget = budget
  }
}

// MARK: Recent expenses section -

private struct RecentExpenses: View {
  @Binding var budget: BudgetModel
  @Binding var editingExpense: ExpenseModel??
  
  var body: some View {
    Button(action: onAddExpenseTapped, label: {
      HStack {
        Text("Add")
        Spacer()
        Image(systemName: "plus.circle")
      }
    })
    
    if (budget.expenses ?? []).isEmpty {
      Text("No expenses")
        .foregroundStyle(.gray)
      
    } else {
      ForEach(
        budget.expenses ?? []
          .sorted(by: {$0.day > $1.day})
          .suffix(3)
      ) { expense in
        Button(action: { onEditExpenseTapped(expense) }) {
          VStack {
            ExpenseListItem(item: expense)
          }
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
      }
      
      NavigationLink(destination: ViewExpenses(budget: $budget)) {
        Text("View all")
      }
    }
  }
  
  private func onAddExpenseTapped() {
    editingExpense = .some(nil)
  }
  
  private func onEditExpenseTapped(_ expense: ExpenseModel) {
    editingExpense = expense
  }
}

// MARK: Preview -

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  let budget = BudgetModel(
    name: "My budget",
    amount: 10000,
    firstDay: .today.adding(days: -3),
    lastDay: .today.adding(days: -1),
    expenses: [])
  container.mainContext.insert(budget)
  
  let expenses = [
    ExpenseModel(
      name: "Expense",
      amount: 10000,
      day: CalendarDate.today),
    ExpenseModel(
      name: "Expense2",
      amount: 10,
      day: CalendarDate.today.adding(days: -10)),
    ExpenseModel(
      name: "Expense 3",
      amount: 10,
      day: CalendarDate.today.adding(days: -1))
  ]
  expenses.forEach {
    container.mainContext.insert($0)
  }
  budget.expenses = expenses
  
  return NavigationView {
    ViewBudget(budget: budget)
  }
  .modelContainer(container)
  .environmentObject(CurrentDate())
}
