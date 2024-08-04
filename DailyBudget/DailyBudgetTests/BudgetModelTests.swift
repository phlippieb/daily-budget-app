import XCTest
import SwiftData
@testable import DailyBudget

final class BudgetModelTests: XCTestCase {
  let container = try! ModelContainer(
    for: BudgetModel.self, ExpenseModel.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: true))
  
  @MainActor func testGetAndSetCalendarDates() {
    // Given a budget and some dates
    let budget = BudgetModel()
    container.mainContext.insert(budget)
    let firstDay = CalendarDate(year: 2000, month: 1, day: 1)
    let lastDay = CalendarDate(year: 2000, month: 1, day: 2)
    
    // When I set the start and end dates as CalendarDates
    budget.firstDay = firstDay
    budget.lastDay = lastDay
    
    // Then I can read those same dates
    XCTAssertEqual(budget.firstDay, firstDay)
    XCTAssertEqual(budget.lastDay, lastDay)
  }
  
  func testTotalDaysIsInclusiveOfEndDate() {
    // Given a budget model with start and end dates one day apart
    let model = BudgetModel(
      name: "",
      notes: "",
      amount: 0,
      firstDay: .init(year: 2000, month: 1, day: 1),
      lastDay: .init(year: 2000, month: 1, day: 2),
      expenses: []
    )
    
    // Then totalDays is 2
    XCTAssertEqual(model.totalDays, 2)
  }
  
  func testDailyAmount() {
    // Given a budget model with 10 total days and a budget of 10
    let model = BudgetModel(
      name: "",
      notes: "",
      amount: 10,
      firstDay: .init(year: 2000, month: 1, day: 1),
      lastDay: .init(year: 2000, month: 1, day: 10),
      expenses: []
    )
    
    // Then dailAmount is 1
    XCTAssertEqual(model.totalDays, 10)
    XCTAssertEqual(model.dailyAmount, 1)
  }
  
  @MainActor func testTotalExpense() {
    // Given a budget model with some expenses
    let expense1 = ExpenseModel(name: "", amount: 1, day: .today)
    let expense2 = ExpenseModel(name: "", amount: 2, day: .today)
    container.mainContext.insert(expense1)
    container.mainContext.insert(expense2)
    
    let model = BudgetModel()
    container.mainContext.insert(model)
    
    model.expenses = [expense1, expense2]
    
    // Then totalExpense adds up correctly
    XCTAssertEqual(model.totalExpenses, 3)
  }
}
