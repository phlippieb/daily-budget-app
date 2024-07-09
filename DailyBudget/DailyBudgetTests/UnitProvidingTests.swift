import XCTest
@testable import DailyBudget

final class UnitProvidingTests: XCTestCase {
  /// # About these tests:
  ///
  /// For `UnitProviding`-conforming models, the units must really be unit in the sense that
  /// comparing two references to the unit returns that they are equal.
  /// This is so that, when binding navigation to a unit acting as an Identifiable, the navigation doesn't
  /// repeatedly show and hide.
  ///
  /// Basically, this fixes a bug where a sheet would repeatedly show and hide because the underlying
  /// default value for a nil binding returned a different id each time it was queried.
  
  func testBudgetModelUnitEquality() {
    XCTAssertEqual(BudgetModel.unit, BudgetModel.unit)
  }
  
  func testExpenseModelUnitEquality() {
    XCTAssertEqual(ExpenseModel.unit, ExpenseModel.unit)
  }
}
