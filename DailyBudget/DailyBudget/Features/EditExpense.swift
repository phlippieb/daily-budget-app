import SwiftUI
import SwiftData

struct EditExpense: View {
  @Binding var expense: ExpenseModel??
  var associatedBudget: BudgetModel = .init()
  
  /// false indicates this is an income
  @State private var isExpense = true
  @State private var name: String = ""
  @State private var amount: Double?
  @State private var date: Date = .now
  @State private var isConfirmDeleteShown = false
  @State private var addAnother = false
  @State private var showingSaveConfirmationForAddAnotherMode = false
  
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
  
  private var isChanged: Bool {
    name != (expense??.name ?? "")
    || (amount ?? 0) != (expense??.amount ?? 0)
    || date != (expense??.date ?? .now)
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
          
          if expense == nil {
            Section {
              Toggle("Add another", isOn: $addAnother)
            } header: {
              Text("Quick entry")
            } footer: {
              if addAnother {
                Text("Add another expense item after saving this one")
              } else {
                Text("Only add this expense item")
              }
            }
          }
          
          if expense != nil {
            Section {
              Button(role: .destructive, action: onDeleteTapped) {
                HStack {
                  Image(systemName: "trash")
                  Text("Delete expense")
                }
              }
              .frame(maxWidth: .infinity)
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
            
          } else {
            focusedField = .name
          }
        }
        
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isChanged)
        
        .toolbar {
          ToolbarItem {
            if showingSaveConfirmationForAddAnotherMode {
              HStack {
                Text("Saved")
                Image(systemName: "checkmark")
              }.foregroundStyle(.secondary)
            } else {
              Button(action: onSaveTapped) { Text("Save") }
                .disabled(isInvalid)
            }
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
    
    if addAnother {
      name = ""
      amount = nil
      date = .now
      expense = .some(nil)
      focusedField = .name
      
      // Display a confirmation
      showingSaveConfirmationForAddAnotherMode = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        showingSaveConfirmationForAddAnotherMode = false
      }
      
    } else {
      expense = nil
    }
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
