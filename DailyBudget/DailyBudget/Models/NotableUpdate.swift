/// All app updates that introduced notable new features with associated "What's New" messages
/// - NOTE: the rawValue **does not** correspond to the app version that introduced the feature
enum NotableUpdate: Int, CaseIterable {
  case widgets = 1
}

extension NotableUpdate {
  static var latest: Self {
    self.allCases.last!
  }
}
