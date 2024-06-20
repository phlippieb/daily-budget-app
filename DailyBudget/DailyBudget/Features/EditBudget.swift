import SwiftUI

struct EditBudget: View {
  enum Mode {
    case new, edit(Budget)
  }
  
  init(
    _ mode: Mode,
    onSave: @escaping (Budget) -> Void = { _ in },
    onDelete: @escaping () -> Void = {}
  ) {
    self.onSave = onSave
    self.onDelete = onDelete
    
    if case .edit(let budget) = mode {
      self.isEditMode = true
      _budget = State(initialValue: Budget(
        name: budget.name,
        amount: budget.amount,
        startDate: budget.startDate,
        endDate: budget.endDate,
        expenses: budget.expenses))
    } else {
      self.isEditMode = false
      _budget = State(initialValue: Budget(
        name: "",
        amount: 0,
        startDate: .now,
        endDate: .now.addingTimeInterval(30*24*60*60),
        expenses: []))
    }
  }
  
  /// Used to check budget date validity
  var currentDate: Date = .now
  
  private let onSave: (Budget) -> Void
  private let onDelete: () -> Void
  private let isEditMode: Bool
  
  @State private var budget: Budget
  
  @State private var isShowingDeleteAlert = false
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          HStack {
            TextField("E.g. Jan daily budget", text: $budget.name)
            
            if budget.name.isEmpty {
              Button(action: onAutoFillName) {
                Image(systemName: "wand.and.stars")
              }
              
            } else {
              Button(action: onClearName) {
                Image(systemName: "xmark.circle")
              }
            }
          }
        } header: {
          Text("Name")
        } footer: {
          if isNameInvalid {
            Text("Budget name is required")
              .foregroundStyle(.red)
          }
        }
        
        Section {
          DatePicker("First day", selection: $budget.startDate, displayedComponents: [.date])
          DatePicker("Last day", selection: $budget.endDate, displayedComponents: [.date])
        } header: {
          Text("Budget period")
        } footer: {
          if isDateInvalid {
            Text("End date must be after start date")
              .foregroundStyle(.red)
          } else if isBudgetInactive {
            Text("Budget period is not currently active")
              .foregroundStyle(.orange)
          }
        }
        
        Section {
          TextField(
            "Amount",
            value: $budget.amount,
            format: .number
          )
          
          if !isAmountInvalid {
            LabeledContent {
              Text("\(budget.dailyAmount, specifier: "%.2f")")
            } label: {
              HStack {
                Image(systemName: "info.circle")
                Text("Daily budget")
              }
            }
            .foregroundStyle(.gray)
          }
        } header: {
          Text("Amount")
        } footer: {
          if isAmountInvalid {
            Text("Amount is required")
              .foregroundStyle(.red)
          } else {
            Text("Total amount available for entire budget period")
          }
        }
        
        if isEditMode {
          Button(role: .destructive, action: onDeleteTapped) {
            HStack {
              Image(systemName: "trash")
              Text("Delete budget")
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle(
        isEditMode ? "Edit budget" : "Create budget"
      )
      .navigationBarTitleDisplayMode(.inline)
      
      .toolbar {
        Button(action: onSaveTapped, label: {
          Text("Save")
        })
        .disabled(isSaveDisabled)
      }
      
      .alert(isPresented: $isShowingDeleteAlert) {
        Alert(
          title: Text("Delete this budget?"),
          primaryButton: .destructive(
            Text("Delete"), action: onDeleteConfirmed),
          secondaryButton: .cancel())
      }
    }
  }
}

// MARK: Actions
private extension EditBudget {
  func onSaveTapped() {
    onSave(budget)
  }
  
  func onDeleteTapped() {
    isShowingDeleteAlert = true
  }
  
  func onDeleteConfirmed() {
    onDelete()
  }
  
  func onAutoFillName() {
    budget.name = getDefaultName()
  }
  
  func getDefaultName() -> String {
    currentDate.formatted(.dateTime.month(.wide).year(.twoDigits)) + " Daily Budget"
  }
  
  func onClearName() {
    budget.name = ""
  }
}

// MARK: Validation
private extension EditBudget {
  var isSaveDisabled: Bool {
    isNameInvalid || isDateInvalid || isAmountInvalid
  }
  
  var isNameInvalid: Bool {
    budget.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  
  var isDateInvalid: Bool {
    budget.endDate <= budget.startDate
  }
  
  var isBudgetInactive: Bool {
    budget.startDate > currentDate || budget.endDate < currentDate
  }
  
  var isAmountInvalid: Bool {
    budget.amount <= 0
  }
}

#Preview {
  EditBudget(.edit(.init(
    name: "Asdf",
    amount: 1000,
    startDate: .now.addingTimeInterval(-10*24*60*60),
    endDate: .now.addingTimeInterval(10*24*60*60),
    expenses: [])))
}
