import SwiftUI

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
              info.currentAllowance > 0 ? .green
              : info.currentAllowance < 0 ? .red
              : .black
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
              info.currentAllowance > 0 ? .black
              : .red
            )
        } label: {
          Text("Budget spent")
        }
      }
    }
  }
}

#Preview {
  BudgetListItem(item: BudgetModel())
    .modelContainer(for: ExpenseModel.self, inMemory: true)
    .environmentObject(CurrentDate())
}
