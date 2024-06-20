import Foundation

/// # Budget model
///
/// Represents a purpose-specific, time-ranged budget and its associated expenses.
/// Ignorant of the current date vis-a-vis the budget's date. See (TODO - model for day-specific view of budget)
struct Budget: Identifiable, Hashable {
  let id = UUID()
  
  var name: String
  var amount: Double
  var startDate: Date
  var endDate: Date
  var expenses: [Expense]
}
