/// All app updates that introduced notable new features with associated "What's New" messages
/// - NOTE: the rawValue **does not** correspond to the app version that introduced the feature
enum NotableUpdate: Int, CaseIterable {
  /// 1.3 adds widgets
  case widgets = 1
  /// 1.4 adds:
  /// - another widget (spent today)
  /// - tapping on widget now goes to correct budget
  /// - savings tips
  /// - improved editing
  /// - launch app on active budget
  case tipsEtc
}

extension NotableUpdate {
  static var latest: Self {
    self.allCases.last!
  }
  
  var version: String {
    switch self {
    case .widgets: return "1.3"
    case .tipsEtc: return "1.4"
    }
  }
}
