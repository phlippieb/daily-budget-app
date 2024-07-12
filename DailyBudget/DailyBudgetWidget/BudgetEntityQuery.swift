import AppIntents
import SwiftData

struct BudgetEntityQuery: EntityQuery {
  func entities(for identifiers: [BudgetEntity.ID]) async throws -> [BudgetEntity] {
    try await fetchEntities()
      .filter { identifiers.contains($0.uuid) }
      .map { BudgetEntity(budget: $0) }
  }

  /// Returns the initial results shown when a list of options backed by this query is presented.
  func suggestedEntities() async throws -> [BudgetEntity] {
    try await fetchEntities()
      .filter {
        BudgetProgressInfo(budget: $0, date: .today).isActive
      }
      .map { BudgetEntity(budget: $0) }
  }
}

private extension BudgetEntityQuery {
  func fetchEntities() async throws -> [BudgetModel] {
    let configuration = ModelConfiguration()
    let fetchDescriptor = FetchDescriptor<BudgetModel>(
      sortBy: [.init(\BudgetModel.endDate, order: .reverse)]
    )

    guard
      let container = try? ModelContainer(
        for: BudgetModel.self, configurations: configuration),
      // TODO: Deal with this warning:
      // Non-sendable type 'ModelContext' in implicitly asynchronous access to main actor-isolated property 'mainContext' cannot cross actor boundary
      let budgetModels = try? await container.mainContext.fetch(fetchDescriptor)
    else {
      return []
    }
    
    return budgetModels
  }
}
