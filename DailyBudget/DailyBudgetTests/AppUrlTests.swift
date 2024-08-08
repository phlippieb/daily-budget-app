import XCTest
@testable import DailyBudget

final class AppUrlTests: XCTestCase {
  func testViewBudgetUrl() {
    let uuid = UUID().uuidString
    XCTAssertEqual(
      AppUrl.viewBudget(uuid: uuid).url?.absoluteString,
      "dailybudget:budget?uuid=\(uuid)")
  }
  
  func testInitViewBudgetFromUrl() {
    let expectedUuid = UUID().uuidString
    let url = URL(string: "dailybudget:budget?uuid=\(expectedUuid)")!
    let appUrl = AppUrl(url)
    
    switch appUrl {
    case .viewBudget(let actualUuid):
      XCTAssertEqual(expectedUuid, actualUuid)
    default:
      XCTFail("AppUrl.init expected to yield viewBudget case")
    }
  }
}
