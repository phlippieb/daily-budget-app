import SwiftUI
import SwiftData

struct EditExpense: View {
  @Binding var expense: ExpenseModel??
  var associatedBudget: BudgetModel? = nil
  let dateRange: ClosedRange<Date>
  
  @State private var name: String = ""
  @State private var amount: Double = 0
  // Note: This is a Date, not a CalendarDate, for use with DatePicker
  @State private var date: Date = .now
  @State private var isConfirmDeleteShown = false
  
  @Environment(\.modelContext) private var modelContext: ModelContext
  
  var body: some View {
    NavigationView {
      if let expense = expense {
        Form {
          Section {
            TextField("Expense name", text: $name)
          } header: {
            Text("Name")
          } footer: {
            if isNameInvalid {
              Text("Budget name is required")
                .foregroundStyle(.red)
            }
          }
          
          Section {
            TextField("Amount", value: $amount, format: .number)
              .keyboardType(.numberPad)
          } header: {
            Text("Amount")
          } footer: {
            if isAmountInvalid {
              Text("Amount is required")
                .foregroundStyle(.red)
            }
          }
          
          Section {
            DatePicker(
              "Date",
              selection: $date,
              in: dateRange,
              displayedComponents: [.date])
          } header: {
            Text("Date")
          } footer: {
            if isDateInvalid {
              Text("Date must fall within budget period")
                .foregroundStyle(.red)
            }
          }
          
          if expense != nil {
            Button(role: .destructive, action: onDeleteTapped) {
              HStack {
                Image(systemName: "trash")
                Text("Delete expense")
              }
            }
            .frame(maxWidth: .infinity)
          }
        }
        .onAppear {
          if let expense {
            name = expense.name
            amount = expense.amount
            date = expense.date
          }
        }
        
        .navigationTitle(
          (expense == nil) ? "Create expense" : "Edit expense"
        )
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
          Button(action: onSaveTapped) { Text("Save") }
            .disabled(isInvalid)
        }
        
        .alert(isPresented: $isConfirmDeleteShown) {
          Alert(
            title: Text("Delete this expense?"),
            primaryButton: .destructive(
              Text("Delete"), action: onConfirmDelete),
            secondaryButton: .cancel())
        }
      }
    }
  }
}

// MARK: Actions
private extension EditExpense {
  func onSaveTapped() {
    switch expense {
    case .some(.some(let expense)):
      expense.name = name
      expense.amount = amount
      expense.date = date
    case .some(.none):
      let newExpense = ExpenseModel(
        name: name,
        amount: amount,
        date: date)
      associatedBudget?.expenses.append(newExpense)
    default:
      break
    }
    
    expense = nil
  }
  
  func onDeleteTapped() {
    isConfirmDeleteShown = true
  }
  
  func onConfirmDelete() {
    if case .some(.some(let expense)) = expense {
      associatedBudget?.expenses.remove(expense)
      modelContext.delete(expense)
    }
    
    expense = nil
  }
}

// MARK: Validation
private extension EditExpense {
  var isInvalid: Bool {
    isNameInvalid || isAmountInvalid || isDateInvalid
  }
  
  var isNameInvalid: Bool {
    name.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  var isAmountInvalid: Bool {
    amount <= 0
  }
  
  var isDateInvalid: Bool {
    date.calendarDate <= dateRange.lowerBound.calendarDate
    || date.calendarDate >= dateRange.upperBound.calendarDate
  }
}

#Preview {
  EditExpense(
    expense: .constant(.some(nil)),
    dateRange: CalendarDate.today.adding(days: -1).date
    ... CalendarDate.today.adding(days: 1).date
  )
  .modelContainer(for: ExpenseModel.self, inMemory: true)
}
