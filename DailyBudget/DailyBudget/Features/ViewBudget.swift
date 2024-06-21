import SwiftUI
import SwiftData

struct ViewBudget: View {
  @State var item: BudgetAtDate
  
  @State private var editingBudget: BudgetModel??
  @State private var editingExpense: ExpenseModel??
  
  var body: some View {
    ScrollView {
      
      // MARK: Today's budget summary
      Group {
        Text("Today").font(.title)
        
        HStack {
          Text(item.date.formatted(.dateTime.day().month().year()))
          Image(systemName: "calendar")
          Text("Day \(item.dayOfBudget) / \(item.budget.totalDays)")
        }
        
        Spacer().frame(height: 20)
        
        if item.currentAllowance < 0 {
          Text("Over budget")
          Text("\(item.currentAllowance, specifier: "%.2f")")
            .font(.largeTitle)
            .foregroundStyle(.red)
        } else {
          Text("Available")
          Text("\(item.currentAllowance, specifier: "%.2f")")
            .font(.largeTitle)
            .foregroundStyle(.green)
        }
      }
      
      // MARK: Budget info
      Spacer().frame(height: 40)
      GroupBox {
        HStack {
          Text("Budget").font(.title)
          Spacer()
          Button(action: onEditBudgetTapped) {
            Image(systemName: "pencil")
          }
        }
        
        LabeledContent {
          Text(
            item.budget.startDate.toStandardFormatting()
            + " - "
            + item.budget.endDate.toStandardFormatting()
          )
        } label: {
          Text("Period")
        }
        
        LabeledContent {
          Text("\(item.budget.amount, specifier: "%.2f")")
        } label: {
          Text("Total budget")
        }
        
        LabeledContent {
          Text("\(item.budget.totalExpenses, specifier: "%.2f")")
        } label: {
          Text("Total spent")
        }
        
        LabeledContent {
          Text("\(item.budget.dailyAmount, specifier: "%.2f")")
        } label: {
          Text("Daily budget")
        }
      }
      .onTapGesture {
        onEditBudgetTapped()
      }
      
      // MARK: Expenses
      Spacer().frame(height: 40)
      Section {
        HStack {
          Text("Expenses").font(.title)
          Spacer()
          Button(action: onAddExpenseTapped) {
            Image(systemName: "plus")
          }
        }
        Spacer().frame(height: 10)
        
        if item.budget.expenses.isEmpty {
          HStack {
            Text("No expenses")
              .foregroundStyle(.gray)
            Spacer()
          }
          .padding(.vertical, 2)
          
        } else {
          ForEach($item.budget.expenses) { expense in
            Button(
              action: { onEditExpense(expense.wrappedValue) }
            ) {
                VStack {
                  ExpenseListItem(item: expense.wrappedValue)
                  Divider()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
    }
    .padding()
    
    .navigationTitle(item.budget.name)
    .navigationBarTitleDisplayMode(.inline)
    
    .sheet(item: $editingBudget, content: { _ in
      EditBudget(budget: $editingBudget)
    })
    
    .sheet(item: $editingExpense) { expense in
      EditExpense(
        expense: $editingExpense,
        associatedBudget: item.budget,
        dateRange: item.budget.dateRange)
    }
  }
}

// MARK: Actions
private extension ViewBudget {
  func onEditBudgetTapped() {
    editingBudget = item.budget
  }
  
  func onAddExpenseTapped() {
    editingExpense = .some(nil)
  }
  
  func onEditExpense(_ expense: ExpenseModel) {
    editingExpense = expense
  }
  
  func onSaveExpense(_ expense: ExpenseModel, newValue: ExpenseModel) {
    editingExpense = nil
    
    guard let index = item.budget.expenses.firstIndex(of: expense)
    else { return }
    
    item.budget.expenses[index] = newValue
  }
}

#Preview {
NavigationView {
    ViewBudget(item: BudgetAtDate(
      budget: .init(
        name: "My budget", amount: 10000,
        startDate: .now.addingTimeInterval(.oneDay * -1),
        endDate: .now.addingTimeInterval(.oneDay * 30),
        expenses: [
          .init(name: "Food", amount: 100, date: .now)
        ]),
      date: .now))
    .modelContainer(for: BudgetModel.self, inMemory: true)
  }
}
