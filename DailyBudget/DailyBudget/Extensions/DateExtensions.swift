import Foundation

extension Date {
  func toStandardFormatting() -> String {
    self.formatted(.dateTime.day().month().year())
  }
}

extension TimeInterval {
  func toDays() -> Int {
    Int(self / .oneDay)
  }
  
  static var oneDay: TimeInterval {
    24 * 60 * 60
  }
}
