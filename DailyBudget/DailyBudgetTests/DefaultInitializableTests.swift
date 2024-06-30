import XCTest
@testable import DailyBudget

/// When initializing a model with the default initializer, as required
/// by the DefaultInitializable protocol, then it must always return a "unit"
/// instance in terms of its Identifiable conformance
final class DefaultInitializableTests: XCTestCase {
  func testBudgetModelDefaultInitIsUnit() {
    XCTAssertEqual(BudgetModel(), BudgetModel())
  }
  
  func testExpenseModelDefaultInitIsUnit() {
    XCTAssertEqual(ExpenseModel(), ExpenseModel())
  }
}
