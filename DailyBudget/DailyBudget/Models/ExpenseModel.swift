import Foundation
import SwiftData

/// # Expense model
///
/// SwiftData-backed model for an expense.
/// An instance represents a single expense associated with a budget.
@Model final class ExpenseModel {
  
  var name: String
  var amount: Double
  var date: Date
  
  init(name: String, amount: Double, date: Date) {
    self.name = name
    self.amount = amount
    self.date = date
  }
}

extension ExpenseModel: DefaultInitializable {
  convenience init() {
    self.init(name: "", amount: 0, date: .now)
  }
}
