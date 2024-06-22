import Foundation

extension Date {
  var calendarDate: CalendarDate {
    CalendarDate(date: self, calendar: .current)
  }
}
