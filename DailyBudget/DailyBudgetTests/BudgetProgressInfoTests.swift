import XCTest
import SwiftData
@testable import DailyBudget

final class BudgetProgressInfoTests: XCTestCase {
  let container = try! ModelContainer(
    for: BudgetModel.self, ExpenseModel.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: true))
  
  func testIsActive() {
    // Given today is 5 Jan 2000
    let day = CalendarDate(year: 2000, month: 1, day: 5)
    
    // Given an active budget
    let activeBudget = BudgetModel()
    activeBudget.startDate = CalendarDate(year: 2000, month: 1, day: 1).date
    activeBudget.endDate = CalendarDate(year: 2000, month: 1, day: 10).date
    
    // Given an inactive budget
    let inactiveBudget = BudgetModel()
    inactiveBudget.startDate = CalendarDate(year: 2000, month: 1, day: 1).date
    inactiveBudget.endDate = CalendarDate(year: 2000, month: 1, day: 3).date
    
    // When I view the budgets in the context of a progress info object
    let activeBudgetInfo = BudgetProgressInfo(budget: activeBudget, date: day)
    let inactiveBudgetInfo = BudgetProgressInfo(budget: inactiveBudget, date: day)
    
    // Then they are respectively active and inactive
    XCTAssertTrue(activeBudgetInfo.isActive)
    XCTAssertFalse(inactiveBudgetInfo.isActive)
  }
  
  func testDayOfBudget() {
    // Given today is 5 Jan 2000
    let day = CalendarDate(year: 2000, month: 1, day: 5)
    
    // Given a budget that starts on 1 Jan 2000
    let budget = BudgetModel()
    budget.startDate = CalendarDate(year: 2000, month: 1, day: 1).date
    
    // When I have the budget's info
    let budgetInfo = BudgetProgressInfo(budget: budget, date: day)
    
    // Then dayOfBudget is 5
    XCTAssertEqual(budgetInfo.dayOfBudget, 5)
  }
  
  @MainActor func testCurrentAllowanceOnDay1() {
    // Given a daily amount of 1
    assertCurrentAllowance(
      budgetAmount: 2,
      budgetEndDate: .init(year: 2000, month: 1, day: 2),
      // When on day 1
      currentDate: .init(year: 2000, month: 1, day: 1)
    ) { dailyAmount in
      // Then the daily amount is 1
      XCTAssertEqual(dailyAmount, 1)
    } assertCurrentAllowance: { currentAllowance in
      // And then the current allowance on day 1 is 1
      XCTAssertEqual(currentAllowance, 1)
    }
  }
  
  @MainActor func testCurrentAllowanceOnDay2() {
    // Given a daily amount of 1
    assertCurrentAllowance(
      budgetAmount: 2,
      budgetEndDate: .init(year: 2000, month: 1, day: 2),
      // When on day 2
      currentDate: .init(year: 2000, month: 1, day: 2)
    ) { dailyAmount in
      // Then the daily amount is 1
      XCTAssertEqual(dailyAmount, 1)
    } assertCurrentAllowance: { currentAllowance in
      // And then the current allowance on day 2 is 2
      XCTAssertEqual(currentAllowance, 2)
    }
  }
  
  @MainActor func testCurrentAllowanceWithExpenses() {
    // Given a daily amount of 1
    assertCurrentAllowance(
      budgetAmount: 2,
      budgetEndDate: .init(year: 2000, month: 1, day: 2),
      // Given total expenses of 1
      budgetTotalExpenses: 1,
      // When on day 1
      currentDate: .init(year: 2000, month: 1, day: 1)
    ) { dailyAmount in
      // Then the daily amount is 1
      XCTAssertEqual(dailyAmount, 1)
    } assertCurrentAllowance: { currentAllowance in
      // And then the current allowance on day 1 is 0
      XCTAssertEqual(currentAllowance, 0)
    }
  }
  
  
  func testCurrentAllowanceIgnoresFutureExpenses() {
    // TODO: Does this matter? Maybe we should prevent future expenses in the UI
    XCTFail("Implement this test")
  }
}

private extension BudgetProgressInfoTests {
  @MainActor func assertCurrentAllowance(
    budgetAmount: Double,
    budgetEndDate: CalendarDate,
    budgetTotalExpenses: Double = 0,
    currentDate: CalendarDate,
    assertDailyAmount: (Double) -> Void,
    assertCurrentAllowance: (Double) -> Void,
    line: UInt = #line
  ) {
    let startDate = CalendarDate(year: 2000, month: 1, day: 1)
    
    let budget = BudgetModel(
      name: "",
      amount: budgetAmount,
      startDate: startDate.date,
      endDate: budgetEndDate.date,
      expenses: [])
    container.mainContext.insert(budget)
    
    let expense = ExpenseModel(
      name: "", amount: budgetTotalExpenses, day: startDate)
    container.mainContext.insert(expense)
    budget.expenses = [expense]
    
    assertDailyAmount(budget.dailyAmount)
    assertCurrentAllowance(BudgetProgressInfo(budget: budget, date: currentDate).currentAllowance)
  }
}
