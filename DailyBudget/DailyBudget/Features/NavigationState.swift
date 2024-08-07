import Foundation
import SwiftData

class NavigationState: ObservableObject {
  @Published var viewingBudget: [BudgetModel] = []
}

// MARK: Handle URL -

extension NavigationState {
  func handle(url: URL, in modelContext: ModelContext) {
    switch AppUrl(url) {
    case .viewBudget(let uuid):
      guard
        let budgets = try? modelContext.fetch(FetchDescriptor<BudgetModel>()),
        let budget = budgets.first(where: { $0.uuid.uuidString == uuid }),
        viewingBudget.last != budget
      else { return }
      
      viewingBudget.append(budget)
      
    default:
      return
    }
  }
}
