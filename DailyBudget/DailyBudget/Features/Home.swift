import SwiftUI
import SwiftData

struct Home: View {
  // TODO: Get from environment
  var date: Date = .now
  
  @Query(sort: \BudgetModel.endDate) private var budgets: [BudgetModel]
  @State private var editingBudget: BudgetModel??
  
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
                ViewBudget(info: .init(budget: budget, date: date))
              } label: {
                BudgetListItem(item: .init(budget: budget, date: date))
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
      
      .sheet(item: $editingBudget) { _ in
        EditBudget(budget: $editingBudget)
      }
    }
  }
  
  private func onAddBudget() {
    editingBudget = .some(nil)
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: ExpenseModel.self, configurations: config)
  
  return Home()
    .modelContainer(container)
}
