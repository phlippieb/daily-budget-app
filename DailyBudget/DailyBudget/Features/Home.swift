import SwiftUI
import SwiftData

// TODO: WidgetCenter.shared.reloadAllTimelines()
//       ^^ this goes somewhere

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
  
  private var appVersion: String? {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  private var buildVersion: String? {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String
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
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      // MARK: App info
      .overlay(alignment: .bottom) {
          if showingAppInfo {
            Spacer()
            VStack {
              Link(destination: URL(string: "https://phlippieb.github.io/daily-budget-app/")!) {
                HStack {
                  Text("Daily Budget")
                  Image(systemName: "safari")
                }
              }
              if let appVersion, let buildVersion {
                Text("Version \(appVersion) (\(buildVersion))")
                  .foregroundStyle(.gray)
              }
            }
            .padding()
            .background(Material.regular)
            .transition(.offset(CGSize(width: 0, height: 150)))
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

// MARK: Preview -

#Preview {
  enum PreviewVariants {
    case singleBudget, multipleBudgets, empty
  }
  let variant = PreviewVariants.multipleBudgets
  
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  
  switch variant {
  case .singleBudget:
    container.mainContext.insert(BudgetModel(
      name: "Current",
      amount: 100,
      startDate: Date.now.addingTimeInterval(300).calendarDate.adding(days: -1).date,
      endDate: Date.now.addingTimeInterval(300),
      expenses: []))
  case .multipleBudgets:
    container.mainContext.insert(BudgetModel(
      name: "Current",
      amount: 100,
      firstDay: .today,
      lastDay: .today.adding(days: 30),
      expenses: []))
    container.mainContext.insert(BudgetModel(
      name: "Upcoming",
      amount: 100,
      firstDay: .today.adding(days: 31),
      lastDay: .today.adding(days: 61),
      expenses: []))
    
    for _ in 0 ... 5 {
      container.mainContext.insert(BudgetModel(
        name: "Past",
        amount: 100,
        firstDay: .today.adding(days: -61),
        lastDay: .today.adding(days: -31),
        expenses: [
          ExpenseModel(name: "", amount: 400, date: .now)
        ]))
    }
  case .empty:
    break
  }
  
  
  return Home()
    .modelContainer(container)
    .environmentObject(CurrentDate())
}
