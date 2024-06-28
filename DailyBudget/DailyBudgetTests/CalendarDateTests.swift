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
  
  func testDaysSince() {
    // Given two dates a day apart
    let calendarDate1 = CalendarDate(year: 2000, month: 1, day: 1)
      .date.addingTimeInterval(7200).calendarDate
    let calendarDate2 = CalendarDate(year: 2000, month: 1, day: 2)
      .date.addingTimeInterval(7200).calendarDate
    let calendarDate3 = CalendarDate(year: 2000, month: 1, day: 3)
      .date.addingTimeInterval(7200).calendarDate
    
    // And given a date on the same day but at a different instant as date 1
    let calendarDate1Later = CalendarDate(
      date: calendarDate1.date.addingTimeInterval(3600))
    let calendarDate1Earlier = CalendarDate(
      date: calendarDate1.date.addingTimeInterval(-3600))
    
    // Then subtraction yields the correct results
    XCTAssertEqual(calendarDate2 - calendarDate1, 1)
    XCTAssertEqual(calendarDate1 - calendarDate2, -1)
    XCTAssertEqual(calendarDate3 - calendarDate1, 2)
    XCTAssertEqual(calendarDate1 - calendarDate1Later, 0)
    XCTAssertEqual(calendarDate1Later - calendarDate1, 0)
    XCTAssertEqual(calendarDate1Earlier - calendarDate1, 0)
  }
  
  func testDaysSinceWithDateComponentsWithDifferentHours() {
    // Given now is 09:00 on 2 Jan 2000
    let today = DateComponents(
      calendar: .current, year: 2000, month: 1, day: 2, hour: 9
    ).date!.calendarDate
    
    // Given a first day of 10:00 on 1 Jan 2000
    let firstDay = DateComponents(
      calendar: .current, year: 2000, month: 1, day: 1, hour: 10
    ).date!.calendarDate
    
    // When I compare today to the first day
    // Then it is 1 day ago
    XCTAssertEqual(today - firstDay, 1)
  }
  
  func testAddingDays() {
    // Given a date created by adding one day to another
    let calendarDate1 = CalendarDate(year: 2000, month: 1, day: 1)
    let calendarDate2 = calendarDate1.adding(days: 1)
    
    // Then the day should be equal to the day after the other
    XCTAssertEqual(calendarDate2, CalendarDate(year: 2000, month: 1, day: 2))
    
    // Given a date create by subtracting 2 days from another
    let calendarDate3 = calendarDate1.adding(days: -2)
    
    // Then the resulting date should be 2 days before the other
    XCTAssertEqual(calendarDate3, CalendarDate(year: 1999, month: 12, day: 30))
  }
  
  func testDifferentTimesWithinSameDayAreEquivalent() {
    // Given "now" is 08:00 noon on 2 Jan 2000
    let now = DateComponents(
      calendar: .current, year: 2000, month: 1, day: 2, hour: 8).date!
    let today = now.calendarDate
    // Given a date range created at 09:00, running from yesterday to today
    let firstDayDate = DateComponents(
      calendar: .current, year: 2000, month: 1, day: 1, hour: 9).date!
    let firstDay = firstDayDate.calendarDate
    let lastDay = firstDay.adding(days: 1)
    let range = firstDay ... lastDay
    
    // When I check where "now" falls in the range
    // Then "now" should be on the last day
    XCTAssertEqual(today, lastDay)
    XCTAssertEqual(lastDay - today, 0)
    XCTAssert(range.contains(today))
  }
  
  func testCalendarDateCreatedFromDateEqualsCreatedFromComponents() {
    // Given 2 dates representing 1 Jan 2000:
    // - one created using the CalendarDate initialiser:
    let day1 = CalendarDate(year: 2000, month: 1, day: 1)
    // - and one created from a Date object:
    let day2Date = DateComponents(
      calendar: .current, year: 2000, month: 1, day: 1).date!
    let day2 = day2Date.calendarDate
    
    // When I compare them
    // Then they are equal
    XCTAssertEqual(day1, day2)
  }
}
