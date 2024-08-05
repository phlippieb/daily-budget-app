import Foundation

class NavigationObject: ObservableObject {
  @Published var viewingBudget: [BudgetModel] = []
}
