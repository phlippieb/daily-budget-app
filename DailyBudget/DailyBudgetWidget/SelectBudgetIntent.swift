import AppIntents

struct SelectBudgetIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Select Budget"
  static var description = IntentDescription("Selects a budget to display information for.")
  
  @Parameter(title: "Budget")
  var budget: BudgetEntity
  
  init(budget: BudgetEntity) {
      self.budget = budget
  }
  
  init() {}
}
