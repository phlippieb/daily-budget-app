import SwiftUI
import SwiftData

struct BudgetListItem: View {
  let item: BudgetModel
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  private var info: BudgetProgressInfo {
    .init(budget: item, date: currentDate.value.calendarDate)
  }
  
  private var dateText: String {
    if info.isActive {
      return "Day \(info.dayOfBudget) of \(item.totalDays)"
    } else if info.isPast {
      return "Ended \(item.lastDay.toStandardFormatting())"
    } else {
      return "Starts \(item.firstDay.toStandardFormatting())"
    }
  }
  
  private var status: String? {
    if item.totalExpenses >= item.amount {
      return "Entire budget depleted"
    } else if info.isActive, info.currentAllowance <= 0 {
      return "Daily allowance depleted"
    } else {
      return nil
    }
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      // MARK: Day/date
      HStack {
        Image(systemName: "calendar")
        Text(dateText)
      }
      .font(.footnote)
      .bold()
      .foregroundStyle(.gray)
      
      // MARK: Budget name
      Text(item.name)
        .font(.title2)
        .padding(.vertical, 1)
      
      // MARK: Amount
      Grid(alignment: .topLeading) {
        if info.isActive {
          GridRow {
            Text("Available today")
            Text("\(info.currentAllowance, specifier: "%.2f")")
              .foregroundStyle(
                info.currentAllowance < 0 ? .red : .label
              )
          }
        }
        
        GridRow {
          Text("Total spent")
          Text("\(item.totalExpenses, specifier: "%.2f") of \(item.amount, specifier: "%.2f")")
            .foregroundStyle(item.totalExpenses > item.amount ? .red : .label)
        }
      }
      
      // MARK: Status
      if let status {
        HStack {
          Image(systemName: "flag")
            .foregroundStyle(.red)
          Text(status)
        }
        .font(.footnote)
        .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
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
