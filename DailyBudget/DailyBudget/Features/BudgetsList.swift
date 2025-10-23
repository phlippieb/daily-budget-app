import SwiftUI

struct BudgetsList: View {
  let title: String
  let budgets: [BudgetModel]
  
  
  var body: some View {
      List {
        ForEach(budgets) { budget in
          NavigationLink {
            ViewBudget(budget: budget)
          } label: {
            BudgetListItem(item: budget)
          }
        }
      }
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
    }
}
