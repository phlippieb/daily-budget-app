import XCTest
@testable import DailyBudget

class CalendarDateTests: XCTestCase {
  func testCalendarDateEquality() {
    // Given two dates at different instances but on the same calendar date
    let calendar = Calendar.current
    let components = DateComponents(year: 2000, month: 1, day: 1)
    let date1 = calendar.date(from: components)!
    let date2 = date1.addingTimeInterval(60)
    
    // When wrapped in calendar dates
    let calendarDate1 = CalendarDate(date: date1)
    let calendarDate2 = CalendarDate(date: date2)
    
    // Then the two dates are equal
    XCTAssertEqual(calendarDate1, calendarDate2)
    
    // Given a third date on another date
//    let date3 = date2.addingTimeInterval(24*60*60)
//    let calendarDate3 = CalendarDate(date: date3)
    let calendarDate3 = calendarDate1.adding(days: 1)
    
    // Then it is not equal to the other dates
    XCTAssertNotEqual(calendarDate1, calendarDate3)
    XCTAssertNotEqual(calendarDate2, calendarDate3)
  }
  
  func testCalendarDateComparison() {
    // Given two dates a day apart
    let calendarDate1 = CalendarDate(year: 2000, month: 1, day: 1)
    let calendarDate2 = CalendarDate(year: 2000, month: 1, day: 2)
    // And given a date on the same day but at a different instant as date 1
    let calendarDate3 = CalendarDate(
      date: calendarDate1.date.addingTimeInterval(60))
    
    // Then the dates a day apart compare correctly
    XCTAssertLessThan(calendarDate1, calendarDate2)
    XCTAssertLessThanOrEqual(calendarDate1, calendarDate2)
    XCTAssertGreaterThan(calendarDate2, calendarDate1)
    XCTAssertGreaterThanOrEqual(calendarDate2, calendarDate1)
    // And the dates on the same day compare correctly
    XCTAssertFalse(calendarDate1 < calendarDate3)
    XCTAssertFalse(calendarDate1 > calendarDate3)
  }
}
