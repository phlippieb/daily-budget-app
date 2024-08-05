import Foundation
import SwiftData

class NavigationObject: ObservableObject {
  @Published var viewingBudget: [BudgetModel] = []
}

// MARK: Handle URL -

extension NavigationObject {
  static func viewingBudgetUrl(uuid: UUID?) -> URL? {
    guard let string = uuid?.uuidString else { return nil }
    return URL(string: string)
  }
  
  func handle(url: URL, in modelContext: ModelContext) {
    // Treat url as a uuid for a BudgetModel instance
    guard
      let uuid = url.pathComponents.first,
      let budgets = try? modelContext.fetch(FetchDescriptor<BudgetModel>()),
      let budget = budgets.first(where: { $0.uuid.uuidString == uuid }),
      viewingBudget.last != budget
    else { return }
    
    viewingBudget.append(budget)
  }
}
