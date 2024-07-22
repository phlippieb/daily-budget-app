import Foundation

// MARK: Persistence provider -

protocol WhatsNewPersistenceProvider {
  var whatsNewLastSeenVersion: AppVersion? { get set }
}

extension UserDefaults: WhatsNewPersistenceProvider {
  var whatsNewLastSeenVersion: AppVersion? {
    get {
      AppVersion(
        intValue: self.value(forKey: whatsNewLastSeenVersionKey) as? Int
      )
    } set {
      self.set(newValue?.intValue, forKey: whatsNewLastSeenVersionKey)
    }
  }
  
  private var whatsNewLastSeenVersionKey: String { "whatsNewLastSeenVersion" }
}

// MARK: What's New Provider -

/// This class indicates whether to display "What's New", given:
/// - a persistence provider that holds the last app version for which a user has seen "What's New", and
/// - the current app version
class WhatsNewProvider {
  init(persistenceProvider: WhatsNewPersistenceProvider = UserDefaults.shared) {
    self.persistenceProvider = persistenceProvider
  }
  
  let latestVersionWithNewMessage = AppVersion(intValue: 1003000)! // 1.3 (0)
  
  func shouldDisplayWhatsNew(for new: AppVersion? = .init()) -> Bool {
    guard
      let old = persistenceProvider.whatsNewLastSeenVersion,
      let new else { return false }
    
    return old.major < new.major || (old.major == new.major && old.minor < new.minor)
  }
  
  func markAsSeen(_ seen: Bool = true, for version: AppVersion? = .init()) {
    persistenceProvider.whatsNewLastSeenVersion = seen ? version : AppVersion(intValue: 0)
  }
  
  fileprivate var persistenceProvider: WhatsNewPersistenceProvider
}

// MARK: What's New datasource for SwiftUI views -

class WhatsNewObservableObject: ObservableObject {
  init(provider: WhatsNewProvider = WhatsNewProvider()) {
    self.provider = provider
    self.shouldDisplay = provider.shouldDisplayWhatsNew()
  }
  
  @Published var shouldDisplay: Bool
  
  var latestVersionWithNewMessage: AppVersion {
    provider.latestVersionWithNewMessage
  }
  
  func markAsSeen(_ seen: Bool = true) {
    provider.markAsSeen(seen)
    shouldDisplay = provider.shouldDisplayWhatsNew()
  }
  
  private let provider: WhatsNewProvider
}
