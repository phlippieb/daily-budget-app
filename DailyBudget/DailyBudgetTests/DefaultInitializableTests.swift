import XCTest
@testable import DailyBudget

final class DefaultInitializableTests: XCTestCase {
  func testBudgetModelDefaultInitIsUnit() {
    XCTAssertEqual(BudgetModel.unit, BudgetModel.unit)
  }
  
  func testExpenseModelDefaultInitIsUnit() {
    XCTAssertEqual(ExpenseModel.unit, ExpenseModel.unit)
  }
}
