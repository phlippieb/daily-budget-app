import SwiftUI
import SwiftData

class CurrentDate: ObservableObject {
  @Published var value = Date.now
}

struct Home: View {
  @Query(sort: \BudgetModel.startDate) private var budgets: [BudgetModel]
  
  @EnvironmentObject private var currentDate: CurrentDate
  
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
                Text("")
                ViewBudget(budget: budget)
              } label: {
                BudgetListItem(item: budget)
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
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  
  return Home()
    .modelContainer(container)
    .environmentObject(CurrentDate())
}
