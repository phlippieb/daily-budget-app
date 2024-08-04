import SwiftUI
import SwiftData

// TODO: -
// - 2. disable or confirm pull down if content was edited

struct EditExpense: View {
  @Binding var expense: ExpenseModel??
  var associatedBudget: BudgetModel = .init()
  
  /// false indicates this is an income
  @State private var isExpense = true
  @State private var name: String = ""
  @State private var amount: Double?
  @State private var date: Date = .now
  @State private var isConfirmDeleteShown = false
  @State private var isChanged = false
  
  private enum FocusField {
    case name, amount
  }
  
  @FocusState private var focusedField: FocusField?
  
  @Environment(\.modelContext) private var modelContext: ModelContext
  
  private var navigationTitle: String {
    switch (expense, isExpense) {
    case (.some(nil), true): return "Add expense"
    case (.some(nil), false): return "Add income"
    case (.some(.some), true): return "Edit expense"
    case (.some(.some), false): return "Edit income"
    case (nil, _): return ""
    }
  }
  
  private var nameTitle: String {
    isExpense ? "Expense name (required)" : "Income name (required)"
  }
  
  private var dateRange: ClosedRange<Date> {
    associatedBudget.startDate ... associatedBudget.endDate
  }
  
  
  var body: some View {
    NavigationView {
      if let expense = expense {
        Form {
          Section {
            Picker("Type", selection: $isExpense) {
              Text("Expense").tag(true)
              Text("Income").tag(false)
            }
            .pickerStyle(.segmented)
            
            TextField(nameTitle, text: $name)
              .submitLabel(.next)
              .focused($focusedField, equals: .name)
            
            HStack {
              TextField("Amount (required)", value: $amount, format: .number)
                .foregroundColor(isExpense ? .none : .green)
                .keyboardType(.numberPad)
                .submitLabel(.done)
                .focused($focusedField, equals: .amount)
              
              Stepper {
              } onIncrement: {
                amount = (amount ?? 0) + 1
              } onDecrement: {
                amount = max(0, (amount ?? 1) - 1)
              }
            }
            
            DatePicker(
              "Date",
              selection: $date,
              in: dateRange,
              displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            
          } footer: {
            if isDateInvalid {
              Text(invalidDateMessage)
                .foregroundStyle(.red)
            }
          }
        }
        
        .onAppear {
          if let expense {
            // TODO: This fixes edits not propogating to the Home view,
            // but it looks weird. Might be better to rethink the data layer.
            associatedBudget.expenses?.append(expense)
            
            name = expense.name
            date = expense.date

            if expense.amount < 0 {
              isExpense = false
              amount = -expense.amount
            } else {
              amount = expense.amount
            }
          }
          
          focusedField = .name
        }
        
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
          ToolbarItem {
            Button(action: onSaveTapped) { Text("Save") }
              .disabled(isInvalid)
          }
          
          if isChanged {
            ToolbarItem(placement: .navigation, content: {
              Button(action: onCancelTapped) { Text("Cancel") }
            })
          }
          
          if focusedField == .name {
            ToolbarItemGroup(placement: .keyboard) {
              Spacer()
              
              Button(action: { focusedField = .amount }) {
                Image(systemName: "arrow.forward")
              }
              
              Button(action:  { focusedField = nil }) {
                Image(systemName: "checkmark")
              }
            }
          }
          
          if focusedField == .amount {
            ToolbarItemGroup(placement: .keyboard) {
              Spacer()
              
              Button(action:  { focusedField = .name }) {
                Image(systemName: "arrow.backward")
              }
              
              Button(action:  { focusedField = nil }) {
                Image(systemName: "checkmark")
              }
            }
          }
        }
        
        .onChange(of: name, { isChanged = true })
        .onChange(of: amount, { isChanged = true })
        .onChange(of: date, { isChanged = true })
        
        .onSubmit {
          switch focusedField {
          case .name: focusedField = .amount
          case .amount, nil: focusedField = nil
          }
        }
        
        .alert(isPresented: $isConfirmDeleteShown) {
          Alert(
            title: Text("Delete this expense?"),
            primaryButton: .destructive(
              Text("Delete"), action: onConfirmDelete),
            secondaryButton: .cancel())
        }
        
        .interactiveDismissDisabled(isChanged)
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
      expense.amount = (isExpense ? amount : -(amount ?? 0)) ?? 0
      expense.date = date
    case .some(.none):
      let newExpense = ExpenseModel(
        name: name,
        amount: (isExpense ? amount : -(amount ?? 0)) ?? 0,
        date: date)
      modelContext.insert(newExpense)
      associatedBudget.expenses?.append(newExpense)
    default:
      break
    }
    
    expense = nil
  }
  
  func onCancelTapped() {
    // Setting the binding to nil dismisses the sheet
    expense = nil
  }
  
  func onDeleteTapped() {
    isConfirmDeleteShown = true
  }
  
  func onConfirmDelete() {
    if case .some(.some(let expense)) = expense {
      associatedBudget.expenses?.remove(expense)
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
    (amount ?? 0) <= 0
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
