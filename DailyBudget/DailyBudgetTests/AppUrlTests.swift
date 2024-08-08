import XCTest
@testable import DailyBudget

final class AppUrlTests: XCTestCase {
  func testViewBudgetUrl() {
    // Given a "view budget" app url for a given UUID
    let uuid = UUID().uuidString
    let appUrl = AppUrl.viewBudget(uuid: uuid)
    
    // When I get the URL value of the app URL
    let url = appUrl.url
    
    // Then it has the expected value
    // When I get the URL
    XCTAssertEqual(
      url?.absoluteString,
      "dailybudget:budget?uuid=\(uuid)")
  }
  
  func testInitViewBudgetFromUrl() {
    // Given a URL for viewing a budget
    let expectedUuid = UUID().uuidString
    let url = URL(string: "dailybudget:budget?uuid=\(expectedUuid)")!
    
    // When I init an AppUrl from this URL
    let appUrl = AppUrl(url)
    
    // Then it yields a "view budget" case
    switch appUrl {
    case .viewBudget(let actualUuid):
      XCTAssertEqual(expectedUuid, actualUuid)
    default:
      XCTFail("AppUrl.init expected to yield viewBudget case")
    }
  }
}
