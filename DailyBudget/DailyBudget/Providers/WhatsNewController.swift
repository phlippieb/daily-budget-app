import Foundation

/// Controls whether "What's New" should be displayed, depending on the current notable update and the
/// last-seen notable update, as indicated by the given persistence provider.
/// Acts as an ObservableObject. This allows Views to show/hide What's New messages depending on
/// `shouldDisplay`.
class WhatsNewController: ObservableObject {
  init(
    persistenceProvider: NotableUpdatePersistenceProvider = UserDefaults.shared
  ) {
    self.persistenceProvider = persistenceProvider
    
    // Suppress the "whats new" message IFF it has been seen for the current
    // most recent notable update
    if let lastSeenNotableUpdate = persistenceProvider.lastSeenNotableUpdate,
       lastSeenNotableUpdate == NotableUpdate.latest {
      shouldDisplay = false
    } else {
      shouldDisplay = true
    }
  }
  
  @Published var shouldDisplay: Bool
  
  func markAsSeen(
    _ seen: Bool = true,
    for notableUpdate: NotableUpdate = .latest
  ) {
    persistenceProvider.lastSeenNotableUpdate = seen ? notableUpdate : nil
    shouldDisplay = !seen
  }
  
  private var persistenceProvider: NotableUpdatePersistenceProvider
}
