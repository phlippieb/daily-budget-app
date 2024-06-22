import SwiftUI
import SwiftData

struct ViewBudget: View {
  @State var info: BudgetProgressInfo
  
  @State private var editingBudget: BudgetModel??
  @State private var editingExpense: ExpenseModel??
  
  var body: some View {
    ScrollView {
      
      // MARK: Today's budget summary
      Group {
        Text("Today").font(.title)
        
        HStack {
          Text(info.date.toStandardFormatting())
          Image(systemName: "calendar")
          Text("Day \(info.dayOfBudget) / \(info.budget.totalDays)")
        }
        
        Spacer().frame(height: 20)
        
        if info.currentAllowance < 0 {
          Text("Over budget")
          Text("\(info.currentAllowance, specifier: "%.2f")")
            .font(.largeTitle)
            .foregroundStyle(.red)
        } else {
          Text("Available")
          Text("\(info.currentAllowance, specifier: "%.2f")")
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
            info.budget.startDate.calendarDate.toStandardFormatting()
            + " - "
            + info.budget.endDate.calendarDate.toStandardFormatting()
          )
        } label: {
          Text("Period")
        }
        
        LabeledContent {
          Text("\(info.budget.amount, specifier: "%.2f")")
        } label: {
          Text("Total budget")
        }
        
        LabeledContent {
          Text("\(info.budget.totalExpenses, specifier: "%.2f")")
        } label: {
          Text("Total spent")
        }
        
        LabeledContent {
          Text("\(info.budget.dailyAmount, specifier: "%.2f")")
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
        
        if info.budget.expenses.isEmpty {
          HStack {
            Text("No expenses")
              .foregroundStyle(.gray)
            Spacer()
          }
          .padding(.vertical, 2)
          
        } else {
          ForEach($info.budget.expenses) { expense in
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
    
    .navigationTitle(info.budget.name)
    .navigationBarTitleDisplayMode(.inline)
    
    .sheet(item: $editingBudget, content: { _ in
      EditBudget(budget: $editingBudget)
    })
    
    .sheet(item: $editingExpense) { expense in
      EditExpense(
        expense: $editingExpense,
        associatedBudget: info.budget,
        dateRange: info.budget.dateRange)
    }
  }
}

// MARK: Actions
private extension ViewBudget {
  func onEditBudgetTapped() {
    editingBudget = info.budget
  }
  
  func onAddExpenseTapped() {
    editingExpense = .some(nil)
  }
  
  func onEditExpense(_ expense: ExpenseModel) {
    editingExpense = expense
  }
}
