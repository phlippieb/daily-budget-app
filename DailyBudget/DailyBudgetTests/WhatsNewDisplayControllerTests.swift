import XCTest
@testable import DailyBudget

final class WhatsNewDisplayControllerTests: XCTestCase {
  /**
   idea -
   only certain releases will have a 'what's new' message that needs to be displayed. when a new release has such a message, the user should see it
   (for simplicity, and for discoverability, i actually think we should always display this, even for new users who didn't upgrade)
   when a new release DOESN'T have such a message, we may display the previous message IF the user hasn't seen it yet.
   
   so -
   - "relevant release" concept for a release with a "what's new" message
   - track the current/most recent "relevant release" (i.e. current)
   - track the last "relevant release" seen and dismissed by the user (i.e. last seen)
   - if current > last seen: show message
   
   so we actually dont care about app versions, except to put it in the message
   we should have an enum instead and have it auto-increment
   this could also enable us to show multiple messages if a user has missed a couple of updates
   */
  
  func testNewUserSeesNewNotableUpdateMessage() {
    // Given the user hasn't seen any notable updates
    let sut = WhatsNewDisplayController(persistenceProvider: mock())
    
    // When a display controller has a most recent notable update
    // Then the user sees the update message
    XCTAssertTrue(sut.shouldDisplay)
  }
  
  func testReturningUserWhoHasSeenCurrentNotableUpdateMessageDoesNotSeeMessage() {
    // Given the user has PREVIOUSLY seen the What's New message for the current notable update
    let sut = WhatsNewDisplayController(persistenceProvider: mock(.widgets))
    
    // Then the user does not see the update message
    XCTAssertFalse(sut.shouldDisplay)
  }
  
  func testMarkingMessageForNotableUpdateSuppressesDisplay() {
    // Given the user has NOT seen any notable updates
    // (Then the user should see the message)
    let sut = WhatsNewDisplayController(persistenceProvider: mock())
    XCTAssertTrue(sut.shouldDisplay)
    
    // When the user marks a notable update as seen
    sut.markAsSeen(for: .widgets)
    
    // Then the user does not see the update message
    XCTAssertFalse(sut.shouldDisplay)
  }
  
  func testMarkingMessageInOneControllerAffectsOtherControllerBackedBySamePersistence() {
    // Given a shared persistence provider for a user who has NOT seen any notable updates
    let persistenceProvider = mock()
    
    // Given a "previous run" instance of a display controller
    let previous = WhatsNewDisplayController(persistenceProvider: persistenceProvider)
    XCTAssertTrue(previous.shouldDisplay)
    
    // When I mark the current version as seen during the previous run
    previous.markAsSeen(for: .widgets)
    XCTAssertFalse(previous.shouldDisplay)
    
    // Given a "next run" instance of a display controller
    let next = WhatsNewDisplayController(persistenceProvider: persistenceProvider)
    
    // Then the next run should also indicate that the message should not display
    XCTAssertFalse(next.shouldDisplay)
  }
}

// MARK: Mocks -

private func mock(_ update: NotableUpdate? = nil) -> WhatsNewDisplayControllerPersistenceProvider {
  MockPersistenceProvider(lastSeenNotableUpdate: update)
}

private class MockPersistenceProvider: WhatsNewDisplayControllerPersistenceProvider {
  init(lastSeenNotableUpdate: NotableUpdate?) {
    self.lastSeenNotableUpdate = lastSeenNotableUpdate
  }
  
  var lastSeenNotableUpdate: NotableUpdate?
}

// MARK: - tdd impl -

/// All app updates that introduced notable new features with associated "What's New" messages
/// - NOTE: the rawValue **does not** correspond to the app version that introduced the feature
enum NotableUpdate: Int, CaseIterable {
  case widgets = 1
  
  static var mostRecent: Self {
    self.allCases.last!
  }
}

protocol WhatsNewDisplayControllerPersistenceProvider {
  var lastSeenNotableUpdate: NotableUpdate? { get set }
}

class WhatsNewDisplayController: ObservableObject {
  init(persistenceProvider: WhatsNewDisplayControllerPersistenceProvider = UserDefaults.shared) {
    // Suppress the "whats new" message IFF it has been seen for the current
    // most recent notable update
    if let lastSeenNotableUpdate = persistenceProvider.lastSeenNotableUpdate,
       lastSeenNotableUpdate == NotableUpdate.mostRecent {
      shouldDisplay = false
    } else {
      shouldDisplay = true
    }
    
    self.persistenceProvider = persistenceProvider
  }
  
  var shouldDisplay: Bool
  
  func markAsSeen(for notableUpdate: NotableUpdate) {
    persistenceProvider.lastSeenNotableUpdate = notableUpdate
    shouldDisplay = false
  }
  
  private var persistenceProvider: WhatsNewDisplayControllerPersistenceProvider
}

extension UserDefaults: WhatsNewDisplayControllerPersistenceProvider {
  var lastSeenNotableUpdate: NotableUpdate? {
    get {
      guard let rawValue = value(forKey: key) as? Int else { return nil }
      return .init(rawValue: rawValue)
    }
    set {
      setValue(newValue?.rawValue, forKey: key)
    }
  }
  
  private var key: String { "lastSeenNotableUpdate" }
}
