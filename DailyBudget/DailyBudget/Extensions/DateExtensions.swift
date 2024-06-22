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

extension Date {
  var calendarDate: CalendarDate {
    CalendarDate(date: self, calendar: .current)
  }
}
