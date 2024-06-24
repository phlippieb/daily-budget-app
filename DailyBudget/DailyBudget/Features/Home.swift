import SwiftUI
import SwiftData

struct Home: View {
  @Query(sort: \BudgetModel.startDate) private var budgets: [BudgetModel]
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  @State private var editingBudget: BudgetModel??
  @State private var showingAppInfo = true
  
  var body: some View {
    NavigationView {
      // MARK: Budgets list
      Group {
        if budgets.isEmpty {
          Button("Add a budget") {
            onAddBudget()
          }
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
      
      // MARK: App info
      .overlay(alignment: .bottom) {
          if showingAppInfo {
            Spacer()
            VStack {
              Link(destination: URL(string: "https://phlippieb.github.io/daily-budget-app/")!) {
                HStack {
                  Text("Daily Budget")
                  Image(systemName: "info.circle")
                }
              }
              Text("Created by Phlippie Bosman")
                .font(.footnote)
            }
            .padding()
            .background(Material.regular)
            .transition(.move(edge: .bottom))
            .cornerRadius(20)
            .padding()
        }
      }
      
      // MARK: Title, toolbar, and adding a new budget
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
      
      // MARK: Show/hide app info
      .animation(.bouncy, value: showingAppInfo)
      .gesture(
        DragGesture().onChanged { value in
          showingAppInfo = (value.translation.height > 0)
        }
      )
    }
  }
  
  private func onAddBudget() {
    editingBudget = .some(nil)
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  container.mainContext.insert(BudgetModel())
  
  return Home()
    .modelContainer(container)
    .environmentObject(CurrentDate())
}
