import WidgetKit

struct BudgetEntry: TimelineEntry {
  var date: Date
  
  /// The selected budget's entity representation, if one is selected
  var entity: BudgetEntity?
}
