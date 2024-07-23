import XCTest
@testable import DailyBudget

final class WhatsNewControllerTests: XCTestCase {
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
    let sut = WhatsNewController(persistenceProvider: mock())
    
    // When a display controller has a most recent notable update
    // Then the user sees the update message
    XCTAssertTrue(sut.shouldDisplay)
  }
  
  func testReturningUserWhoHasSeenCurrentNotableUpdateMessageDoesNotSeeMessage() {
    // Given the user has PREVIOUSLY seen the What's New message for the current notable update
    let sut = WhatsNewController(persistenceProvider: mock(.widgets))
    
    // Then the user does not see the update message
    XCTAssertFalse(sut.shouldDisplay)
  }
  
  func testMarkingMessageSeenSuppressesDisplay() {
    // Given the user has NOT seen any notable updates
    // (Then the user should see the message)
    let sut = WhatsNewController(persistenceProvider: mock())
    XCTAssertTrue(sut.shouldDisplay)
    
    // When the user marks a notable update as seen
    sut.markAsSeen(for: .widgets)
    
    // Then the user does not see the update message
    XCTAssertFalse(sut.shouldDisplay)
  }
  
  func testMarkingMessageSeenAffectsNextRun() {
    // Given a shared persistence provider for a user who has NOT seen any notable updates
    let persistenceProvider = mock()
    
    // Given a "previous run" instance of a display controller
    let previous = WhatsNewController(persistenceProvider: persistenceProvider)
    XCTAssertTrue(previous.shouldDisplay)
    
    // When I mark the current version as seen during the previous run
    previous.markAsSeen(for: .widgets)
    XCTAssertFalse(previous.shouldDisplay)
    
    // Then the next run should also indicate that the message should not display
    let next = WhatsNewController(persistenceProvider: persistenceProvider)
    XCTAssertFalse(next.shouldDisplay)
  }
  
  func testMarkingMessageUnseenAffectsNextRun() {
    // Given a shared persistence provider for a user who HAS seen any notable updates
    let persistenceProvider = mock(.widgets)
    
    // Given a "previous run" instance of a display controller
    let previous = WhatsNewController(persistenceProvider: persistenceProvider)
    XCTAssertFalse(previous.shouldDisplay)
    
    // When I mark the current version as unseen during the previous run
    previous.markAsSeen(false, for: .widgets)
    XCTAssertTrue(previous.shouldDisplay)
    
    // Then the next run should also indicate that the message should not display
    let next = WhatsNewController(persistenceProvider: persistenceProvider)
    XCTAssertTrue(next.shouldDisplay)
  }
}

// MARK: Mocks -

private func mock(_ update: NotableUpdate? = nil) -> NotableUpdatePersistenceProvider {
  MockPersistenceProvider(lastSeenNotableUpdate: update)
}

private class MockPersistenceProvider: NotableUpdatePersistenceProvider {
  init(lastSeenNotableUpdate: NotableUpdate?) {
    self.lastSeenNotableUpdate = lastSeenNotableUpdate
  }
  
  var lastSeenNotableUpdate: NotableUpdate?
}
