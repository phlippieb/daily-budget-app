import SwiftUI

struct BudgetsList: View {
  let title: String
  let budgets: [BudgetModel]
  
  var budgetsByYear: [(String, [BudgetModel])] {
    Dictionary(grouping: budgets) { budget in
      Calendar.current.component(.year, from: budget.startDate)
    }
    .sorted { $0.0 > $1.0 }
    .map { (String($0.0), $0.1) }
  }
  
  var body: some View {
      List {
        ForEach(budgetsByYear, id: \.0) { (year, budgets) in
          Section(year) {
            ForEach(budgets) { budget in
              NavigationLink {
                ViewBudget(budget: budget)
              } label: {
                BudgetListItem(item: budget)
              }
            }
          }
        }
      }
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
    }
}
