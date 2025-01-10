enum CsvEncoder {
  static func encode(_ budgets: [BudgetModel]) -> String {
    "budgetUUID,budgetName,budgetNotes,budgetAmount,budgetFirstDay,budgetLastDay,expenseName,expenseNotes,expenseAmount,expenseDate\n"
    + budgets.flatMap { budget in
      (budget.expenses?.nonEmpty ?? [.empty])
        .map { expense in
          [
            budget.uuid.uuidString,
            budget.name,
            budget.notes,
            budget.amount.formatted(.number),
            budget.firstDay.csvFormat,
            budget.lastDay.csvFormat,
            expense.name,
            (expense.name.isEmpty) ? "" : expense.notes,
            (expense.name.isEmpty) ? "" : expense.amount.formatted(.number),
            (expense.name.isEmpty) ? "" : expense.day.csvFormat,
          ].joined(separator: ",")
        }
    }.joined(separator: "\n")
  }
}

private extension ExpenseModel {
  static let empty = ExpenseModel(name: "", notes: "", amount: 0, date: .distantFuture)
}

private extension CalendarDate {
  /// - Returns: e.g. "2000/1/31"
  var csvFormat: String {
    self.date.formatted(.dateTime.year(.defaultDigits).month(.twoDigits).day(.twoDigits))
  }
}
