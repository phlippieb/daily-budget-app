import SwiftUI
import SwiftData

struct Home: View {
  @Query(sort: \BudgetModel.startDate) private var budgets: [BudgetModel]
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  @State private var editingBudget: BudgetModel??
  @State private var showingAppInfo = true
  
  var body: some View {
    NavigationView {
      ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
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
        .frame(maxHeight: .infinity)
        
        Group {
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
            .background(
              Material.regular
            )
            .transition(.offset(.init(width: 0, height: 100)))
          }
        }
        .cornerRadius(20)
        .padding()
        
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
  
      // MARK: Show/hide app info
      .gesture(
        DragGesture().onChanged { value in
          showingAppInfo = (value.translation.height > 0)
        }
      )
      .animation(.easeInOut, value: showingAppInfo)
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
