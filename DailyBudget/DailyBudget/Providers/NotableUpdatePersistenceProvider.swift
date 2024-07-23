import Foundation

protocol NotableUpdatePersistenceProvider {
  var lastSeenNotableUpdate: NotableUpdate? { get set }
}

extension UserDefaults: NotableUpdatePersistenceProvider {
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
