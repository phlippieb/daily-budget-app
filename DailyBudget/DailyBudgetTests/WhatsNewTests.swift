import XCTest
@testable import DailyBudget

final class WhatsNewTests: XCTestCase {
  func testNewUserDoesNotSeeWhatsNew() {
    // Given a WhatsNewProvider with no relevant values in user defaults
    let sut = WhatsNewProvider(persistenceProvider: mock())
    let currentAppVersion = AppVersion(from: mock(appVersion: "1.2", buildVersion: "3"))!
    
    // When I query whether to display What's New
    // Then it should be false
    XCTAssertFalse(sut.shouldDisplayWhatsNew(for: currentAppVersion))
  }
  
  func testReturningUserDoesNotSeeWhatsNewForSameVersion() {
    // Given a WhatsNewProvider where the user has marked What's New as seen
    // for the current app version
    let sut = WhatsNewProvider(persistenceProvider: mock())
    let currentAppVersion = AppVersion(from: mock(appVersion: "1.2", buildVersion: "3"))!
    sut.markAsSeen(for: currentAppVersion)
    
    // When I query whether to display What's New
    // Then it should be false
    XCTAssertFalse(sut.shouldDisplayWhatsNew(for: currentAppVersion))
  }
  
  func testReturningUserSeesWhatsNewForNewVersion() {
    // Given a previous and current app version
    let previousAppVersion = AppVersion(from: mock(appVersion: "1.2", buildVersion: "3"))!
    let currentAppVersion = AppVersion(from: mock(appVersion: "1.3", buildVersion: "2"))!
    // Given a WhatsNewProvider where the user has marked What's New as seen
    // for the previous app version
    let sut = WhatsNewProvider(persistenceProvider: mock())
    sut.markAsSeen(for: previousAppVersion)
    
    // When I query whether to display What's New
    // Then it should be true
    XCTAssertTrue(sut.shouldDisplayWhatsNew(for: currentAppVersion))
  }
  
  func testSeenVersionPersistsAcrossWhatsNewInstances() {
    // Given a common persistence provider
    let persistenceProvider: WhatsNewPersistenceProvider = mock()
    // Given a previous and current app version
    let previousAppVersion = AppVersion(from: mock(appVersion: "1.1", buildVersion: "0"))!
    let currentAppVersion = AppVersion(from: mock(appVersion: "1.2", buildVersion: "0"))!
    // Given two instances of WhatsNewProvider, representing two runs of the app
    let previousSut = WhatsNewProvider(persistenceProvider: persistenceProvider)
    let sut = WhatsNewProvider(persistenceProvider: persistenceProvider)
    
    // When I mark the old version as seen in one instance, representing a
    // previous run of the app
    previousSut.markAsSeen(for: previousAppVersion)
    
    // Then the current instance should indicate that What's New should be
    // displayed
    XCTAssertTrue(sut.shouldDisplayWhatsNew(for: currentAppVersion))
  }
  
  /// Note: We can't easily unit-test that persistence really works between app runs,
  /// but we can ensure that the implementation is based on a known, working framework
  func testDefaultInitUsesUserDefaultsForPersistence() {
    // NOTE: This test requires access to `persistenceProvider`, which has been
    // refactored out of access.

//    // Given a default-initialised WhatsNewProvider
//    let sut = WhatsNewProvider()
//    
//    // Then the underlying persistence provider is a UserDefaults instance
//    XCTAssert(sut.persistenceProvider is UserDefaults)
  }
}


// MARK: Mock persistence provider -

private func mock() -> WhatsNewPersistenceProvider {
  MockPersistenceProvider()
}

private class MockPersistenceProvider: WhatsNewPersistenceProvider {
  // Simple in-memory implementation
  var whatsNewLastSeenVersion: AppVersion? = nil
}

// MARK: Mock app version -

private func mock(
  appVersion: String, buildVersion: String
) -> AppVersionProvider {
  MockAppVersionProvider(appVersion: appVersion, buildVersion: buildVersion)
}

private struct MockAppVersionProvider: AppVersionProvider {
  var appVersion: String?
  var buildVersion: String?
}
