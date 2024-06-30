import SwiftUI
import SwiftData

struct ViewBudget: View {
  // TODO: Should this be a binding?
  @State var budget: BudgetModel
  
  @State private var editingBudget: BudgetModel??
  @State private var editingExpense: ExpenseModel??
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  private var info: BudgetProgressInfo {
    .init(budget: budget, date: currentDate.value.calendarDate)
  }
  
  var body: some View {
    VStack {
      if info.isActive {
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
        
      } else if info.isPast {
        // MARK: Summary of a past budget
        Text("Ended on "
             + budget.lastDay.toStandardFormatting())
        
        Spacer().frame(height: 20)
        Text("Amount spent")
        Text(
          "\(budget.totalExpenses, specifier: "%.2f") / \(budget.amount, specifier: "%.2f")"
        )
        .font(.title)
        .foregroundStyle(
          budget.totalExpenses <= budget.amount ? Color.label : .red
        )
        
      } else {
        // MARK: Summary of a future budget
        Text("Starts on "
             + budget.firstDay.toStandardFormatting()
        )
        
        Spacer().frame(height: 20)
        Text("Amount")
        Text(
          "\(budget.amount, specifier: "%.2f")"
        )
        .font(.title)
      }
      
      // MARK: Budget info
      Spacer().frame(height: 40)
      GroupBox {
        HStack {
          Text("Budget").font(.headline)
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
        VStack {
          HStack {
            Text("Recent expenses").font(.headline)
            Spacer()
            Button(action: onAddExpenseTapped) {
              Image(systemName: "plus")
            }
          }
          Spacer().frame(height: 10)
          
          if info.budget.expenses?.isEmpty ?? true {
            HStack {
              Text("No expenses")
                .foregroundStyle(.gray)
              Spacer()
            }
            .padding(.vertical, 2)
            
          } else {
            ForEach(
              budget.expenses?
                .sorted(by: {$0.day > $1.day})
                .suffix(3) ?? []
            ) { expense in
              Button(
                action: { onEditExpense(expense) }
              ) {
                VStack {
                  ExpenseListItem(item: expense)
                  Divider()
                }
                .contentShape(Rectangle())
              }
              .buttonStyle(PlainButtonStyle())
            }
            
            NavigationLink(
              destination: ViewExpenses(budget: $budget)
            ) {
              Text("View all")
            }
            .padding()
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
        associatedBudget: info.budget)
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

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  
  let budget = BudgetModel(
    name: "My budget",
    amount: 10000,
    firstDay: .today.adding(days: 1),
    lastDay: .today.adding(days: 1),
    expenses: [])
  container.mainContext.insert(budget)
  
  let expenses = (1 ... 10).map { i in
    ExpenseModel(name: "Expense \(i)", amount: Double(20 * i), day: CalendarDate.today.adding(days: i/4))
  }
  expenses.forEach { container.mainContext.insert($0) }
  budget.expenses = expenses
  
  return NavigationStack {
    ViewBudget(budget: budget)
  }
  .modelContainer(container)
  .environmentObject(CurrentDate())
}
