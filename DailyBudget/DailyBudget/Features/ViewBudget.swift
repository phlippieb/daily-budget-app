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
      ForEach(sections, id: \.0) { (title, content, action) in
        Section {
          content
        } header: {
          HStack {
            Text(title)
            if let action {
              Spacer()
              action
            }
          }
        }
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
    
    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        Button(action: { editingBudget = budget }, label: {
          Image(systemName: "pencil.line")
        })
      }
      
      ToolbarItem(placement: .bottomBar) {
        Button(action: { editingExpense = .some(.none) }, label: {
          Image(systemName: "plus.circle")
        })
      }
    }
  }
  
  private typealias ViewBudgetSection = (
    title: String, body: AnyView, action: AnyView?)
  
  private var sections: [ViewBudgetSection] {
    [
      // TODO: Cleanup? Move to view?
      (title: info.isActive ? "Today" : "Summary",
       body: .init(TodaySummary(viewModel: info.summaryViewModel)),
       action: nil),
      (title: "Budget info",
       body: .init(BudgetInfo(
        budget: budget, editingBudget: $editingBudget)),
       action: .init(Button(action: { editingBudget = budget }, label: {
         HStack { Text("Edit"); Image(systemName: "pencil.line") }
       }))
      ),
      (title: "Recent expenses", body: .init(RecentExpenses(
        expenses: budget.expenses ?? [],
        budget: $budget,
        editingExpense: $editingExpense)),
       action: .init(Button(action: { editingExpense = .some(.none) }, label: { HStack { Text("Add"); Image(systemName: "plus.circle") }})))
    ]
  }
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
        Text(viewModel.dateSummary)
        
        if let status = viewModel.status {
          Spacer()
          Image(systemName: "flag")
            .foregroundStyle(.red)
          Text(status)
        }
      }
      .font(.footnote)
      
      // MARK: Primary amount
      Text("")
      Text(viewModel.primaryAmountTitle)
      AmountText(amount: viewModel.primaryAmount, wholePartFont: .largeTitle)
        .bold()
        .foregroundStyle(viewModel.accentColor)
      
      // MARK: Secondary amount
      if let secondaryAmountTitle = viewModel.secondaryAmountTitle, let secondaryAmount = viewModel.secondaryAmount {
        Divider()
        Text("")
        Text(secondaryAmountTitle)
        HStack(spacing: 0) {
          AmountText(amount: secondaryAmount)
          
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
          .init(color: viewModel.backgroundAccentColor.opacity(0.3), location: 0.9),
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
    ForEach(items, id: \.0) { (title, content) in
      LabeledContent(title, content: { content })
    }
    
    //    Button("Edit budget", action: onEditBudgetTapped)
    Button(action: onEditBudgetTapped) {
      HStack {
        Text("Edit")
        Spacer()
        Image(systemName: "pencil.line")
      }
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
  let expenses: [ExpenseModel] // TODO: Duplicates budget now
  @Binding var budget: BudgetModel
  @Binding var editingExpense: ExpenseModel??
  
  var body: some View {
    
    if expenses.isEmpty {
      Text("No expenses")
        .foregroundStyle(.gray)
      
    } else {
      ForEach(
        expenses
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
    firstDay: .today.adding(days: -10),
    lastDay: .today.adding(days: -1),
    expenses: [])
  container.mainContext.insert(budget)
  
  let expenses = [
    ExpenseModel(
      name: "Expense",
      amount: 100,
      day: CalendarDate.today),
    ExpenseModel(
      name: "Expense2",
      amount: 10,
      day: CalendarDate.today.adding(days: -1)),
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
