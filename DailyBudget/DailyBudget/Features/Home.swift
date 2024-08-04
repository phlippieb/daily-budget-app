import SwiftUI
import SwiftData

struct Home: View {
  @Query(sort: \BudgetModel.startDate) private var budgets: [BudgetModel]
  
  @EnvironmentObject private var currentDate: CurrentDate
  @EnvironmentObject private var whatsNew: WhatsNewController
  
  @State private var editingBudget: BudgetModel??
  @State private var showingAppInfo = true
  
  private var activeBudgets: [BudgetModel] {
    budgets.active(on: currentDate.value.calendarDate)
  }
  
  private var upcomingBudgets: [BudgetModel] {
    budgets.upcoming(on: currentDate.value.calendarDate)
  }
  
  private var pastBudgets: [BudgetModel] {
    budgets.past(on: currentDate.value.calendarDate)
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
            if whatsNew.shouldDisplay {
              WhatsNew()
            }
            
            if !activeBudgets.isEmpty {
              Section("Current budgets") {
                ForEach(activeBudgets) { budget in
                  BudgetListItem(item: budget)
                    .overlay {
                      NavigationLink(
                        destination: ViewBudget(budget: budget)) {}
                        .opacity(0)
                    }
                }
              }
            }
            
            if !upcomingBudgets.isEmpty {
              Section("Upcoming budgets") {
                ForEach(upcomingBudgets) { budget in
                  BudgetListItem(item: budget)
                    .overlay {
                      NavigationLink(
                        destination: ViewBudget(budget: budget)) {}
                        .opacity(0)
                    }
                }
              }
            }
            
            if !pastBudgets.isEmpty {
              Section("Past budgets") {
                ForEach(pastBudgets) { budget in
                  BudgetListItem(item: budget)
                    .overlay {
                      NavigationLink(
                        destination: ViewBudget(budget: budget)) {}
                        .opacity(0)
                    }
                }
              }
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      
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
      
      // MARK: App info
      .overlay(alignment: .bottom) {
        if showingAppInfo {
          AppInfo()
        }
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

// MARK: Filtering budgets -

private extension Array where Element == BudgetModel {
  func active(on today: CalendarDate) -> [BudgetModel] {
    filter { ($0.firstDay ... $0.lastDay).contains(today) }
  }
  
  func upcoming(on today: CalendarDate) -> [BudgetModel] {
    filter { $0.firstDay > today }
  }
  
  func past(on today: CalendarDate) -> [BudgetModel] {
    filter { $0.lastDay < today }
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
      notes: "",
      amount: 100,
      startDate: Date.now.addingTimeInterval(300).calendarDate.adding(days: -1).date,
      endDate: Date.now.addingTimeInterval(300),
      expenses: []))
  case .multipleBudgets:
    container.mainContext.insert(BudgetModel(
      name: "Current",
      notes: "",
      amount: 100,
      firstDay: .today,
      lastDay: .today.adding(days: 30),
      expenses: []))
    container.mainContext.insert(BudgetModel(
      name: "Upcoming",
      notes: "",
      amount: 100,
      firstDay: .today.adding(days: 31),
      lastDay: .today.adding(days: 61),
      expenses: []))
    
    for _ in 0 ... 5 {
      container.mainContext.insert(BudgetModel(
        name: "Past",
        notes: "",
        amount: 100,
        firstDay: .today.adding(days: -61),
        lastDay: .today.adding(days: -31),
        expenses: [
          ExpenseModel(name: "", notes: "", amount: 400, date: .now)
        ]))
    }
  case .empty:
    break
  }
  
  return Home()
    .modelContainer(container)
    .environmentObject(CurrentDate())
    .environmentObject(WhatsNewController())
}
