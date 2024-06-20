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
      self.budget.name = budget.name
      self.budget.amount = budget.amount
      self.budget.startDate = budget.startDate
      self.budget.endDate = budget.endDate
    } else {
      self.isEditMode = false
    }
  }
  
  private let onSave: (Budget) -> Void
  private let onDelete: () -> Void
  private let isEditMode: Bool
  
  @State private var budget = Budget(
    name: "", 
    amount: 0,
    startDate: .now,
    endDate: .now.addingTimeInterval(30*24*60*60),
    expenses: [])
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("E.g. Jan daily budget", text: $budget.name)
        } header: {
          Text("Name")
        } footer: {
          if isNameInvalid {
            Text("Budget name is required")
              .foregroundStyle(.red)
          }
        }
        
        Section("Budget period") {
          DatePicker("First day", selection: $budget.startDate, displayedComponents: [.date])
          DatePicker("Last day", selection: $budget.endDate, displayedComponents: [.date])
        }
        
        Section {
          TextField(
            "Amount",
            value: $budget.amount,
            format: .number
          )
          
          LabeledContent {
            Text("\(budget.dailyAmount, specifier: "%.2f")")
          } label: {
            HStack {
              Image(systemName: "info.circle")
              Text("Daily budget")
            }
          }
          .foregroundStyle(.gray)
        } header: {
          Text("Amount")
        } footer: {
          Text("Total amount available for entire budget period")
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
    }
  }
  
  private func onSaveTapped() {
    onSave(budget)
  }
  
  private func onDeleteTapped() {
    onDelete()
  }
  
  private var isSaveDisabled: Bool {
    isNameInvalid
  }
  
  private var isNameInvalid: Bool {
    budget.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}

#Preview {
  EditBudget(.new)
}
