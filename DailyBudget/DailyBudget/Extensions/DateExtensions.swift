import Foundation

// TODO: Remove?
extension TimeInterval {
  func toDays() -> Int {
    Int(self / .oneDay)
  }
  
  static var oneDay: TimeInterval {
    24 * 60 * 60
  }
}
