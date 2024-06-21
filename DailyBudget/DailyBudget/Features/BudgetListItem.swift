import SwiftUI

struct BudgetListItem: View {
  let item: BudgetProgressInfo
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(item.budget.name)
        .font(.title2)
      
      if item.isActive {
        Text("Day \(item.dayOfBudget) / \(item.budget.totalDays)")
      } else {
        Text("Ended \(item.budget.endDate.toStandardFormatting())")
      }
      
      if item.isActive {
        // View for an active budget:
        // Show the amount available today after expenses
        LabeledContent {
          Text("\(item.currentAllowance, specifier: "%.2f")")
            .font(.title)
            .foregroundStyle(
              item.currentAllowance > 0 ? .green
              : item.currentAllowance < 0 ? .red
              : .black
            )
        } label: {
          Text("Available")
        }
        
      } else {
        // View for a future or expire budget:
        // Show the final amount spent
        LabeledContent {
          Text("\(item.budget.totalExpenses, specifier: "%.2f") / \(item.budget.amount, specifier: "%.2f")")
            .foregroundStyle(
              item.currentAllowance > 0 ? .black
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
  NavigationView {
    List {
      // Active budget
      BudgetListItem(
        item: .init(
          budget: .init(
            name: "Monthly budget",
            amount: 10000,
            startDate: .now.addingTimeInterval(-10*24*60*60),
            endDate: .now.addingTimeInterval(10*24*60*60),
            expenses: []),
          date: .now)
      )
      
      // Active budget
      BudgetListItem(
        item: .init(
          budget: .init(
            name: "Monthly budget",
            amount: 10000,
            startDate: .now.addingTimeInterval(-60*24*60*60),
            endDate: .now.addingTimeInterval(-30*24*60*60),
            expenses: []),
          date: .now)
      )
    }
  }
}
