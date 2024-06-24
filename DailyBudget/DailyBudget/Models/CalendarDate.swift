import Foundation

/// Provides ergonomics for treating Swift Dates at day-specific granularity
struct CalendarDate {
  let date: Date
  private var calendar: Calendar { .current }
}

// MARK: Creating instances -

extension CalendarDate {
  static var today: CalendarDate {
    .init(date: .now)
  }
  
  init(year: Int, month: Int, day: Int) {
    self.init(
      date: Calendar.current.date(
        from: DateComponents(year: year, month: month, day: day))!)
  }
  
  func adding(days: Int) -> CalendarDate {
    CalendarDate(
      date: calendar.date(
        byAdding: DateComponents(day: days), to: date)!)
  }
}

// MARK: Days since -

extension CalendarDate {
  static func -(lhs: CalendarDate, rhs: CalendarDate) -> Int {
    Int(lhs.date.timeIntervalSince(rhs.date) / 24 / 60 / 60)
  }
}

// MARK: Nice formating -

extension CalendarDate {
  func toStandardFormatting() -> String {
    self.date.formatted(.dateTime.day().month().year())
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

// MARK: Hashable -

extension CalendarDate: Hashable {
  /// Custom implementation with day granularity
  func hash(into hasher: inout Hasher) {
    calendar.dateComponents([.year, .month, .day], from: date)
      .hash(into: &hasher)
  }
}
