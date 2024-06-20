import SwiftUI

struct Home: View {
  @State var budgets: [Budget] = []
  @State private var isCreateVisible = false
  var date: Date = .now
  
  var body: some View {
    NavigationView {
      NavigationStack {
        if budgets.isEmpty {
          Text("No budgets")
            .foregroundStyle(.gray)
          
        } else {
          List {
            ForEach(budgets) { budget in
              BudgetListItem(
                item: BudgetAtDate(budget: budget, date: date))
            }
          }
        }
      }
      
      .navigationTitle("Budgets")
      .navigationBarTitleDisplayMode(.inline)
      
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button(action: onAddBudget, label: {
            Image(systemName: "plus")
          })
        }
      }
    }
  }
  
  private func onAddBudget() {
    // TODO
  }
}

#Preview {
  Home(
    budgets: [
      Budget(
        name: "June monthly budget",
        amount: 10000,
        startDate: Date.now.addingTimeInterval(-10*24*60*60),
        endDate: Date.now.addingTimeInterval(20*24*60*60),
        expenses: [
          Expense(name: "Food", amount: 1000, date: .now)
        ]
      ),
      
      Budget(
        name: "May monthly budget",
        amount: 10000,
        startDate: Date.now.addingTimeInterval(-40*24*60*60),
        endDate: Date.now.addingTimeInterval(-10*24*60*60),
        expenses: [
          Expense(name: "Food", amount: 1000, date: .now)
        ]
      )
    ]
  )
}
