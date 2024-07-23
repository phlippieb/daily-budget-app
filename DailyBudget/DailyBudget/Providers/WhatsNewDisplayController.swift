import Foundation

/// Controls whether "What's New" should be displayed, depending on the current notable update and the
/// last-seen notable update, as indicated by the given persistence provider.
/// Acts as an ObservableObject. This allows Views to show/hide What's New messages depending on
/// `shouldDisplay`.
class WhatsNewController: ObservableObject {
  typealias PersistenceProvider = LastSeenNotableUpdatePersistenceProvider
  
  init(
    persistenceProvider: PersistenceProvider = UserDefaults.shared
  ) {
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
  
  @Published var shouldDisplay: Bool
  
  func markAsSeen(for notableUpdate: NotableUpdate) {
    persistenceProvider.lastSeenNotableUpdate = notableUpdate
    shouldDisplay = false
  }
  
  private var persistenceProvider: PersistenceProvider
}
