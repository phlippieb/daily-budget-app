import Foundation

/// Provides ergonomics for treating Swift Dates at day-specific granularity
struct CalendarDate {
  let date: Date
  var calendar: Calendar = .current
}

// MARK: Creating instances -

extension CalendarDate {
  static var today: CalendarDate {
    .init(date: .now)
  }
  
  init(year: Int, month: Int, day: Int, calendar: Calendar = .current) {
    self.init(
      date: calendar.date(
        from: DateComponents(year: year, month: month, day: day))!,
      calendar: calendar)
  }
  
  func adding(days: Int) -> CalendarDate {
    CalendarDate(date: date.addingTimeInterval(24*60*60), calendar: calendar)
  }
}

// MARK: Comparisons -

extension CalendarDate: Equatable {
  static func ==(lhs: CalendarDate, rhs: CalendarDate) -> Bool {
    Calendar.current.isDate(lhs.date, equalTo: rhs.date, toGranularity: .day)
  }
}

extension CalendarDate: Comparable {
  static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
    lhs != rhs && lhs.date < rhs.date
  }
}
