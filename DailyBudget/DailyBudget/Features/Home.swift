import SwiftUI
import SwiftData

struct Home: View {
  @Query(sort: \BudgetModel.startDate) private var budgets: [BudgetModel]
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  @State private var editingBudget: BudgetModel??
  @State private var showingAppInfo = true
  
  private var activeBudgets: [BudgetModel] {
    budgets.filter { budget in
      (budget.firstDay ... budget.lastDay)
        .contains(currentDate.value.calendarDate)
    }
  }
  
  private var upcomingBudgets: [BudgetModel] {
    budgets.filter { budget in
      budget.firstDay > currentDate.value.calendarDate
    }
  }
  
  private var pastBudgets: [BudgetModel] {
    budgets.filter { budget in
      budget.lastDay < currentDate.value.calendarDate
    }
  }
  
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
            if !activeBudgets.isEmpty {
              Section("Current budgets") {
                ForEach(activeBudgets) { budget in
                  NavigationLink {
                    Text("")
                    ViewBudget(budget: budget)
                  } label: {
                    BudgetListItem(item: budget)
                  }
                }
              }
            }
            
            if !upcomingBudgets.isEmpty {
              Section("Upcoming budgets") {
                ForEach(upcomingBudgets) { budget in
                  NavigationLink {
                    Text("")
                    ViewBudget(budget: budget)
                  } label: {
                    BudgetListItem(item: budget)
                  }
                }
              }
            }
            
            if !pastBudgets.isEmpty {
              Section("Past budgets") {
                ForEach(pastBudgets) { budget in
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
        ToolbarItemGroup(placement: .topBarLeading) {
          Button(action: onSettingsTapped) { 
            Image(systemName: "gearshape")
          }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button(action: onAddBudget) {
            Image(systemName: "plus")
          }
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
  
  private func onSettingsTapped() {
    guard 
      let url = URL(string: UIApplication.openSettingsURLString),
      UIApplication.shared.canOpenURL(url)
    else { return }
    
    UIApplication.shared.open(url)
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  container.mainContext.insert(BudgetModel())
  container.mainContext.insert(BudgetModel(
    name: "Upcoming",
    amount: 100,
    firstDay: .today.adding(days: 31),
    lastDay: .today.adding(days: 61),
    expenses: []))
  
  return Home()
    .modelContainer(container)
    .environmentObject(CurrentDate())
}
