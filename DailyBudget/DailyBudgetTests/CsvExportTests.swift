import Testing

@testable import DailyBudget

@Test func testExportCsv() throws {
  // Given some budgets
  let budgetWithoutExpenses = BudgetModel(
    name: "My budget 1",
    notes: "My notes",
    amount: 99,
    firstDay: CalendarDate(year: 2000, month: 1, day: 2),
    lastDay: CalendarDate(year: 2000, month: 3, day: 4),
    expenses: [])
  
  let expense1 = ExpenseModel(
    name: "Expense 1",
    notes: "Notes 1",
    amount: 11,
    date: CalendarDate(year: 2000, month: 6, day: 6).date)
  let expense2 = ExpenseModel(
    name: "Expense 2",
    notes: "",
    amount: 12,
    date: CalendarDate(year: 2000, month: 7, day: 7).date)
  let budgetWithExpenses = BudgetModel(
    name: "My budget 2",
    notes: "",
    amount: 111,
    firstDay: CalendarDate(year: 2000, month: 5, day: 6),
    lastDay: CalendarDate(year: 2000, month: 7, day: 8),
    expenses: [expense1, expense2])
  
  let budgets: [BudgetModel] = [budgetWithoutExpenses, budgetWithExpenses]
  
  // When I encode to CSV
  let csv = try CsvEncoder.encode(budgets)
  let rows = csv.components(separatedBy: .newlines)
  
  // Then the CSV has the correct header row
  let headerRow = try #require(rows.first)
  let headerColumns = headerRow.components(separatedBy: ",")
  #expect(headerColumns == [
    "budgetUUID",
    "budgetName",
    "budgetNotes",
    "budgetAmount",
    "budgetFirstDay",
    "budgetLastDay",
    "expenseName",
    "expenseNotes",
    "expenseAmount",
    "expenseDate"])
  
  // And then the CSV has rows for all expected budgets/transactions
  let budgetRows = rows.dropFirst().map { $0 }
  try #require(budgetRows.count == 3)
  
  // And then row 0 matches the first budget's info
  do {
    let row = try #require(budgetRows.item(at: 0)).components(separatedBy: ",")
    try #require(row.count == 10)
    #expect(row[0] == budgetWithoutExpenses.uuid.uuidString)
    #expect(row[1] == budgetWithoutExpenses.name)
    #expect(row[2] == budgetWithoutExpenses.notes)
    #expect(row[3] == "99")
    #expect(row[4] == "2000/01/02")
    #expect(row[5] == "2000/03/04")
    #expect(row[6] == "") // Name
    #expect(row[7] == "") // Notes
    #expect(row[8] == "") // Amount
    #expect(row[9] == "") // Date
  }
  
  // And then row 1 matches the second budget's info and its first transaction
  do {
    let row = try #require(budgetRows.item(at: 1)).components(separatedBy: ",")
    try #require(row.count == 10)
    #expect(row[0] == budgetWithExpenses.uuid.uuidString)
    #expect(row[1] == budgetWithExpenses.name)
    #expect(row[2] == budgetWithExpenses.notes)
    #expect(row[3] == "111")
    #expect(row[4] == "2000/05/06")
    #expect(row[5] == "2000/07/08")
    #expect(row[6] == expense1.name)
    #expect(row[7] == expense1.notes)
    #expect(row[8] == "11")
    #expect(row[9] == "2000/06/06")
  }
  
  // And then row 2 matches the second budget's info and its second transaction
  do {
    let row = try #require(budgetRows.item(at: 2)).components(separatedBy: ",")
    try #require(row.count == 10)
    #expect(row[0] == budgetWithExpenses.uuid.uuidString)
    #expect(row[1] == budgetWithExpenses.name)
    #expect(row[2] == budgetWithExpenses.notes)
    #expect(row[3] == "111")
    #expect(row[4] == "2000/05/06")
    #expect(row[5] == "2000/07/08")
    #expect(row[6] == expense2.name)
    #expect(row[7] == expense2.notes)
    #expect(row[8] == "12")
    #expect(row[9] == "2000/07/07")
  }
}
