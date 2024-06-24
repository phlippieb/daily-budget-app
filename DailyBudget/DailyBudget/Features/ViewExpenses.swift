import SwiftUI
import SwiftData

struct ViewExpenses: View {
  @Binding var budget: BudgetModel
  
  @State private var editingExpense: ExpenseModel??
  
  var body: some View {
    List {
      ForEach(budget.expenses.groupedByDate, id: \.0) { group in
        Section {
          ForEach(group.1) { expense in
            Button(action: { onEditExpense(expense) }, label: {
              ExpenseListItem(item: expense)
                .contentShape(Rectangle())
            })
            .buttonStyle(PlainButtonStyle())
          }
        } header: {
          HStack {
            Text(group.0.toStandardFormatting())
            Spacer()
            Text("Total: \(group.1.map(\.amount).reduce(0, +), specifier: "%.2f")")
          }
        }
      }
    }
    .navigationTitle(budget.name)
    .navigationBarTitleDisplayMode(.inline)
    
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button(action: onAddExpenseTapped) {
          Image(systemName: "plus")
        }
      }
    }
    
    .sheet(item: $editingExpense) { expense in
      EditExpense(
        expense: $editingExpense,
        associatedBudget: budget,
        // TODO: date range can now be inferred from associated budget
        dateRange: budget.firstDay ... budget.lastDay)
    }
  }
}

// MARK: Group and sort expenses -
private extension Array where Element == ExpenseModel {
  var groupedByDate: [(CalendarDate, [ExpenseModel])] {
    groupsByDate
      .map { ($0, $1) }
      .sorted(by: { $0.0 > $1.0 })
  }
  
  private var groupsByDate: [CalendarDate: [ExpenseModel]] {
    .init(
      grouping: self.sorted(by: { $0.day < $1.day }),
      by: \.date.calendarDate)
  }
}

// MARK: Actions -
private extension ViewExpenses {
  func onAddExpenseTapped() {
    editingExpense = .some(nil)
  }
  
  func onEditExpense(_ expense: ExpenseModel) {
    editingExpense = expense
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  let budget = BudgetModel()
  budget.name = "My budget"
  container.mainContext.insert(budget)
  var expenses = (1 ... 10).map { i in
    ExpenseModel(name: "Expense \(i)", amount: Double(1 * i), day: CalendarDate.today.adding(days: i/3))
  }
  expenses.forEach { container.mainContext.insert($0) }
  budget.expenses = expenses
  
  return NavigationView {
    ViewExpenses(budget: .constant(budget))
      .modelContainer(container)
      .environmentObject(CurrentDate())
  }
}
