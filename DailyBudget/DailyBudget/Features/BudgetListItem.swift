import SwiftUI
import SwiftData

struct BudgetListItem: View {
  let item: BudgetModel
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  private var info: BudgetProgressInfo {
    .init(budget: item, date: currentDate.value.calendarDate)
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(item.name)
        .font(.title2)
      
      if info.isActive {
        Text("Day \(info.dayOfBudget) / \(item.totalDays)")
      } else {
        Text("Ended \(item.endDate.calendarDate.toStandardFormatting())")
      }
      
      if info.isActive {
        // View for an active budget:
        // Show the amount available today after expenses
        LabeledContent {
          Text("\(info.currentAllowance, specifier: "%.2f")")
            .font(.title)
            .foregroundStyle(
              info.currentAllowance >= 0 ? .green : .red
            )
        } label: {
          Text("Available")
        }
        
      } else {
        // View for a future or expire budget:
        // Show the final amount spent
        LabeledContent {
          Text("\(item.totalExpenses, specifier: "%.2f") / \(item.amount, specifier: "%.2f")")
            .foregroundStyle(
              info.budget.totalExpenses <= info.budget.amount ? Color(UIColor.label) : .red
            )
        } label: {
          Text("Budget spent")
        }
      }
    }
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
