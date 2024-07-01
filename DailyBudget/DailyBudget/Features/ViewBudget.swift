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

//        Section(title) { content }
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
      (info.isActive)
      ? (title: "Today", body: .init(Today(info: info)), action: nil)
      : (title: "Summary", body: .init(PastBudgetSummary(budget: budget)), action: nil),
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

// MARK: Today section -
// For active budgets

private struct Today: View {
  let info: BudgetProgressInfo
  
  private var accentColor: Color {
    info.currentAllowance < 0 ? .red : .green
  }
  
  private var status: String? {
    if info.budget.totalExpenses >= info.budget.amount {
      return "Entire budget depleted"
    } else if info.isActive, info.currentAllowance <= 0 {
      return "Daily allowance depleted"
    } else {
      return nil
    }
  }
  
  private let cornerRadius: CGFloat = 10
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "calendar")
        Text("Day \(info.dayOfBudget) of \(info.budget.totalDays)")
        
        if let status {
          Spacer()
          Image(systemName: "flag")
            .foregroundStyle(.red)
          Text(status)
        }
      }
      .font(.footnote)
      
      Text("")
      Text("Available")
      HStack(alignment: .lastTextBaseline, spacing: 0) {
        AmountText(amount: info.currentAllowance, wholePartFont: .largeTitle).bold()
          .foregroundStyle(accentColor)
        Text(" of ")
        AmountText(
          amount: info.budget.dailyAmount,
          wholePartFont: .body)
        // TODO: ^^ what makes the most sense to display here, and below?
      }
      
      Divider()
      Text("")
      Text("Spent")
      HStack(alignment: .lastTextBaseline, spacing: 0) {
        // TODO: Get only amount spent today
        AmountText(amount: info.budget.totalExpenses)
        Text(" of ")
        AmountText(amount: info.budget.dailyAmount)
      }
    }
    .listRowBackground(
      LinearGradient(
        stops: [
          .init(color: .secondarySystemGroupedBackground, location: 0.4),
          .init(color: accentColor.opacity(0.2), location: 1),
        ],
        startPoint: UnitPoint.topLeading, endPoint: .bottomTrailing
      )
    )
  }
}

// MARK: Past budget section -

private struct PastBudgetSummary: View {
  let budget: BudgetModel
  
  private var status: String? {
    if budget.totalExpenses > budget.amount {
      return "Budget exceeded"
    } else {
      return nil
    }
  }
  
  private var accentColor: Color {
    budget.totalExpenses > budget.amount ? .red : .green
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "calendar")
        Text("Ended \(budget.lastDay.toStandardFormatting())")
        
        if let status {
          Spacer()
          Image(systemName: "flag")
            .foregroundStyle(.red)
          Text(status)
        }
      }
      .font(.footnote)
      
      Text("")
      Text((budget.totalExpenses > budget.amount ? "Over" : "Under") + " budget by")
      AmountText(
        amount: abs(budget.amount - budget.totalExpenses),
        wholePartFont: .largeTitle
      )
      .bold()
      .foregroundColor(accentColor)
      
      Divider()
      Text("")
      Text("Total spent")
      HStack(alignment: .lastTextBaseline, spacing: 0) {
        AmountText(amount: budget.totalExpenses)
        Text(" of ")
        AmountText(amount: budget.amount)
      }
    }
    .listRowBackground(
      LinearGradient(
        stops: [
          .init(color: .secondarySystemGroupedBackground, location: 0.4),
          .init(color: .secondary.opacity(0.1), location: 1),
        ],
        startPoint: UnitPoint.topLeading, endPoint: .bottomTrailing
      )
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
    firstDay: .today.adding(days: -31),
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
