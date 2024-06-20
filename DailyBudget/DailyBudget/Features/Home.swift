import SwiftUI

struct Home: View {
  @State var budgets: [Budget] = []
  var date: Date = .now
  
  @State private var isAddBudgetVisible = false
  
  var body: some View {
    NavigationView {
      Group {
        if budgets.isEmpty {
          Text("No budgets")
            .foregroundStyle(.gray)
          
        } else {
          List {
            ForEach(budgets) { budget in
              NavigationLink {
                ViewBudget(item: .init(
                  budget: budget, date: date))
              } label: {
                BudgetListItem(
                  item: BudgetAtDate(budget: budget, date: date))
              }
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
      
      .sheet(isPresented: $isAddBudgetVisible) {
        EditBudget(.new, onSave: { newBudget in
          self.budgets.insert(newBudget, at: 0)
          self.isAddBudgetVisible = false
        })
      }
    }
  }
  
  private func onAddBudget() {
    isAddBudgetVisible = true
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
