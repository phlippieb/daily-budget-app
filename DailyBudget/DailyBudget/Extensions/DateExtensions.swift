import Foundation

extension TimeInterval {
  func toDays() -> Int {
    Int(self / 24 / 60 / 60)
  }
}
