import SwiftUI
import SwiftData

struct EditBudget: View {
  @Binding var budget: BudgetModel??
  // TODO: Rather use environmentObject to provide current date
  var currentDate: Date = .now
  
  @State private var name: String = ""
  @State private var amount: Double = 0
  @State private var startDate: Date = CalendarDate.today.date
  @State private var endDate: Date = CalendarDate.today.adding(days: 30).date
  @State private var isShowingDeleteAlert = false
  
  @Environment(\.modelContext) private var modelContext: ModelContext
  
  private var dailyAmount: Double {
    let totalDays = (endDate.calendarDate - startDate.calendarDate) + 1
    return amount / Double(totalDays)
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          HStack {
            TextField(getDefaultName(), text: $name)
            
            if name.isEmpty {
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
          DatePicker("First day", selection: $startDate, displayedComponents: [.date])
          DatePicker("Last day", selection: $endDate, displayedComponents: [.date])
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
          TextField("Amount", value: $amount, format: .number)
            .keyboardType(.numberPad)
          
          if !isAmountInvalid {
            LabeledContent {
              Text("\(dailyAmount, specifier: "%.2f")")
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
        
        if case .some(.some(_)) = budget {
          Button(role: .destructive, action: onDeleteTapped) {
            HStack {
              Image(systemName: "trash")
              Text("Delete budget")
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      
      .onAppear {
        if case .some(.some(let budget)) = budget {
          name = budget.name
          amount = budget.amount
          startDate = budget.startDate
          endDate = budget.endDate
        }
      }
      
      .navigationTitle(
        (budget != nil) ? "Edit budget" : "Create budget"
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
    switch budget {
    case .some(.some(let budget)):
      budget.name = name
      budget.amount = amount
      budget.startDate = startDate
      budget.endDate = endDate
    case .some(.none):
      let newBudget = BudgetModel(
        name: name, 
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        expenses: [])
      modelContext.insert(newBudget)
    default:
      break
    }
    
    budget = nil
  }
  
  func onDeleteTapped() {
    isShowingDeleteAlert = true
  }
  
  func onDeleteConfirmed() {
    if case .some(.some(let budget)) = budget {
      modelContext.delete(budget)
    }
    
    budget = nil
  }
  
  func onAutoFillName() {
    name = getDefaultName()
  }
  
  func getDefaultName() -> String {
    currentDate.formatted(.dateTime.month(.wide).year(.twoDigits)) + " Daily Budget"
  }
  
  func onClearName() {
    name = ""
  }
}

// MARK: Validation
private extension EditBudget {
  var isSaveDisabled: Bool {
    isNameInvalid || isDateInvalid || isAmountInvalid
  }
  
  var isNameInvalid: Bool {
    name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  
  var isDateInvalid: Bool {
    // NOTE: First and last day may be the same
    endDate.calendarDate < startDate.calendarDate
  }
  
  var isBudgetInactive: Bool {
    startDate.calendarDate > currentDate.calendarDate
    || endDate.calendarDate < currentDate.calendarDate
  }
  
  var isAmountInvalid: Bool {
    amount <= 0
  }
}

#Preview {
  EditBudget(
    budget: .constant(.some(nil)),
    currentDate: .now
  )
  .modelContainer(for: BudgetModel.self)
}
