import AppIntents

/// Entity representation of a BudgetModel
struct BudgetEntity: AppEntity, Identifiable {
  typealias ID = UUID
  var id: ID
  var name: String
  
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
  }
  
  // TODO: Can we use this to pre-select the most recent budget?
  static var defaultQuery = BudgetEntityQuery()
  
  static var typeDisplayRepresentation: TypeDisplayRepresentation = "Budget"
  
  init(id: ID, name: String) {
    self.id = id
    self.name = name
  }
  
  init(budget: BudgetModel) {
    self.id = budget.uuid
    self.name = budget.name
  }
}
