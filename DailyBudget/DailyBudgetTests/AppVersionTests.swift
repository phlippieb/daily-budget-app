import XCTest
@testable import DailyBudget

final class AppVersionTests: XCTestCase {
  func testComparingMajorVersions() {
    // Given two AppVersions:
    // - one from app version "1.2" and build version "3"
    // - one from app version "1.3" and build version "3"
    let sut1 = AppVersion(from: mock(appVersion: "1.2", buildVersion: "3"))!
    let sut2 = AppVersion(from: mock(appVersion: "1.3", buildVersion: "3"))!
    
    // When I inspect the major versions
    // Then they are correct
    XCTAssertEqual(sut1.major, 1)
    XCTAssertEqual(sut2.major, 1)
  }
  
  func testDefaultAppVersionProvider() {
    // Given an AppVersion that uses the default app version provider
    let sut = AppVersion()!
    
    // When I check the major and minor version
    // Then it corresponds to the current app version
    XCTAssertEqual(
      "\(sut.major).\(sut.minor)",
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    )
    
    // When I check the build bersion
    // Then it corresponds to the current build version
    XCTAssertEqual(
      "\(sut.build)",
      Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    )
  }
}

// MARK: Mocks -

private func mock(
  appVersion: String, buildVersion: String
) -> some AppVersionProvider {
  MockAppVersionProvider(appVersion: appVersion, buildVersion: buildVersion)
}

private struct MockAppVersionProvider: AppVersionProvider {
  var appVersion: String?
  var buildVersion: String?
}
