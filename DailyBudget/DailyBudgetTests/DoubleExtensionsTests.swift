import XCTest
@testable import DailyBudget

final class DoubleExtensionsTests: XCTestCase {
  func testWholePart() {
    XCTAssertEqual(Double(123.456).wholePart, 123)
    XCTAssertEqual(Double(0.1).wholePart, 0)
  }
}
