import XCTest
@testable import DailyBudget

final class AppVersionTests: XCTestCase {
  func testAppVersionToInts() {
    // Given two AppVersions:
    // - one from app version "1.2" and build version "3"
    // - one from app version "4.5" and build version "6"
    let sut1 = AppVersion(from: mock(appVersion: "1.2", buildVersion: "3"))!
    let sut2 = AppVersion(from: mock(appVersion: "4.5", buildVersion: "6"))!
    
    // When I get int representations of the AppVersions
    // Then the ints are correct
    XCTAssertEqual(sut1.intValue, 001002003)
    XCTAssertEqual(sut2.intValue, 004005006)
  }
  
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
  
  func testInitFromIntValue() {
    // Given some int values for app versions
    let int1 = 001002003
    let int2 = 004005006
    let int3 = 987654321
    
    // When I init AppVersions from the values
    let sut1 = AppVersion(intValue: int1)!
    let sut2 = AppVersion(intValue: int2)!
    let sut3 = AppVersion(intValue: int3)!
    
    // Then the resulting AppVersions are correct
    XCTAssertEqual(sut1.major, 1)
    XCTAssertEqual(sut1.minor, 2)
    XCTAssertEqual(sut1.build, 3)
    
    XCTAssertEqual(sut2.major, 4)
    XCTAssertEqual(sut2.minor, 5)
    XCTAssertEqual(sut2.build, 6)
    
    XCTAssertEqual(sut3.major, 987)
    XCTAssertEqual(sut3.minor, 654)
    XCTAssertEqual(sut3.build, 321)
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
