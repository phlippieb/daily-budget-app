import SwiftUI
import SwiftData

struct Home: View {
  @Query(sort: \BudgetModel.startDate) private var budgets: [BudgetModel]
  
  @EnvironmentObject private var currentDate: CurrentDate
  @EnvironmentObject private var whatsNew: WhatsNewController
  @EnvironmentObject private var navigation: NavigationObject
  
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
    NavigationStack(path: $navigation.viewingBudget) {
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
            
            budgetsSection("Current budgets", activeBudgets)
            budgetsSection("Upcoming budgets", upcomingBudgets)
            budgetsSection("Past budgets", pastBudgets)
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
      
      // MARK: Navigation
      .navigationDestination(for: BudgetModel.self) {
        ViewBudget(budget: $0)
      }
      
      // MARK: Auto-nav if there is only one budget
      .onAppear {
        if
          navigation.viewingBudget.isEmpty,
          activeBudgets.count == 1 {
          navigation.viewingBudget = [activeBudgets[0]]
        }
      }
    }
  }
  
  private func budgetsSection(
    _ title: String, _ budgets: [BudgetModel]
  ) -> some View {
    guard !budgets.isEmpty else { return AnyView(EmptyView()) }
    
    return AnyView(
      Section(title) {
        ForEach(budgets) { budget in
          BudgetListItem(item: budget)
            .overlay {
              NavigationLink(value: budget, label: {}).opacity(0)
            }
        }
      }
    )
  }
}

// MARK: Actions -
private extension Home {
  func onAddBudget() {
    editingBudget = .some(nil)
  }
  
  func onSettingsTapped() {
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
    .environmentObject(NavigationObject())
}
