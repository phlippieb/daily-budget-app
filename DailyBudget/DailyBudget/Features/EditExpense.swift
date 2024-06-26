import SwiftUI
import SwiftData

struct EditExpense: View {
  @Binding var expense: ExpenseModel??
  var associatedBudget: BudgetModel = .init()
  
  /// false indicates this is an income
  @State private var isExpense = true
  @State private var name: String = ""
  @State private var amount: Double = 0
  @State private var date: Date = .now
  @State private var isConfirmDeleteShown = false
  
  @Environment(\.modelContext) private var modelContext: ModelContext
  
  private var dateRange: ClosedRange<Date> {
    associatedBudget.startDate ... associatedBudget.endDate
  }
  
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
            HStack {
              Picker("Type", selection: $isExpense) {
                Text("Expense").tag(true)
                Text("Income").tag(false)
              }
              .pickerStyle(.segmented)
              
              TextField("Amount", value: $amount, format: .number)
                .keyboardType(.numberPad)
                .foregroundColor(isExpense ? .none : .green)
                .multilineTextAlignment(.trailing)
            }
            
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
              Text(invalidDateMessage)
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
            // TODO: This fixes edits not propogating to the Home view,
            // but it looks weird. Might be better to rethink the data layer.
            associatedBudget.expenses.append(expense)
            
            name = expense.name
            date = expense.date

            if expense.amount < 0 {
              isExpense = false
              amount = -expense.amount
            } else {
              amount = expense.amount
            }
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

// MARK: Actions -
private extension EditExpense {
  func onSaveTapped() {
    switch expense {
    case .some(.some(let expense)):
      expense.name = name
      expense.amount = isExpense ? amount : -amount
      expense.date = date
      // TODO: signal to associatedBudget that it updated?
    case .some(.none):
      let newExpense = ExpenseModel(
        name: name,
        amount: isExpense ? amount : -amount,
        date: date)
      modelContext.insert(newExpense)
      associatedBudget.expenses.append(newExpense)
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
      associatedBudget.expenses.remove(expense)
      modelContext.delete(expense)
    }
    
    expense = nil
  }
}

// MARK: Validation -
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
    date.calendarDate < dateRange.lowerBound.calendarDate
    || date.calendarDate > dateRange.upperBound.calendarDate
  }
  
  var invalidDateMessage: String {
    "Date must fall within budget period ("
    + dateRange.lowerBound.calendarDate.toStandardFormatting() + " - "
    + dateRange.upperBound.calendarDate.toStandardFormatting() + ")"
  }
}

#Preview {
  EditExpense(
    expense: .constant(.some(nil)))
  .modelContainer(for: ExpenseModel.self, inMemory: true)
}
