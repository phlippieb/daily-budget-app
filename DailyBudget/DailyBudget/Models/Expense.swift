import Foundation

/// # Expense model
///
/// Represents a single expense associated with a budget.
struct Expense: Identifiable, Hashable {
  let id = UUID()
  
  var name: String
  var amount: Double
  var date: Date
}
