import SwiftUI

struct EditExpense: View {
  enum Mode {
    case new, edit(Expense)
  }
  
  init(
    _ mode: Mode,
    onSave: @escaping (Expense) -> Void = { _ in }
  ) {
    // TODO: Enforce date within budget date range
    self.onSave = onSave
    
    if case .edit(let expense) = mode {
      isEditMode = true
      _item = State(initialValue: .init(
        name: expense.name, amount: expense.amount, date: expense.date))
    } else {
      isEditMode = false
      _item = State(initialValue: .init(
        name: "", amount: 0, date: .now))
    }
  }
  
  private let isEditMode: Bool
  private let onSave: (Expense) -> Void
  
  @State private var item: Expense
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Expense name", text: $item.name)
        } header: {
          Text("Name")
        } footer: {
          if isNameInvalid {
            Text("Budget name is required")
              .foregroundStyle(.red)
          }
        }
        
        Section {
          TextField("Amount", value: $item.amount, format: .number)
        } header: {
          Text("Amount")
        } footer: {
          if isAmountInvalid {
            Text("Amount is required")
              .foregroundStyle(.red)
          }
        }
        
        Section {
          DatePicker("Date", selection: $item.date, displayedComponents: [.date])
        } header: {
          Text("Date")
        } footer: {
          if isDateInvalid {
            Text("Date must fall within budget period")
              .foregroundStyle(.red)
          }
        }
        
        if isEditMode {
          Button(role: .destructive, action: onDeleteTapped) {
            HStack {
              Image(systemName: "trash")
              Text("Delete expense")
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle(
        isEditMode ? "Edit expense" : "Create expense"
      )
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button(action: onSaveTapped) { Text("Save") }
          .disabled(isInvalid)
      }
    }
  }
}

// MARK: Actions
private extension EditExpense {
  func onSaveTapped() {
    onSave(item)
  }
  
  func onDeleteTapped() {
    
  }
}

// MARK: Validation
private extension EditExpense {
  var isInvalid: Bool {
    isNameInvalid || isAmountInvalid || isDateInvalid
  }
  
  var isNameInvalid: Bool {
    item.name.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  var isAmountInvalid: Bool {
    item.amount <= 0
  }
  
  var isDateInvalid: Bool {
    false // TODO
  }
}

#Preview {
//  EditExpense(.new)
  EditExpense(.edit(.init(name: "My expense", amount: 100, date: .now)))
}
