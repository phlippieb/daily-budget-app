import SwiftUI
import SwiftData

struct EditBudget: View {
  @Binding var budget: BudgetModel??
  var currentDate: CalendarDate { .today }
  
  @State private var name: String = ""
  @State private var notes: String = "Notes"
  @State private var amount: Double?
  @State private var startDate: Date = CalendarDate.today.date
  @State private var endDate: Date = CalendarDate.today.adding(days: 30).date
  @State private var isShowingDeleteAlert = false
  
  private enum FocusField {
    case name, notes, amount
  }
  
  @FocusState private var focusedField: FocusField?
  
  @Environment(\.modelContext) private var modelContext: ModelContext
  
  private var title: String {
    if case .some(.none) = budget {
      return "Create budget"
    } else {
      return "Edit budget"
    }
  }
  
  private let notesPlaceholder = "Notes"
  
  private var dailyAmount: Double {
    let totalDays = (endDate.calendarDate - startDate.calendarDate) + 1
    return (amount ?? 0) / Double(totalDays)
  }
  
  private var isChanged: Bool {
    name != (budget??.name ?? "")
    || notes != (budget??.notes ?? notesPlaceholder)
    || (amount ?? 0) != (budget??.amount ?? 0)
    || startDate != (budget??.startDate ?? CalendarDate.today.date)
    || endDate != (budget??.endDate ?? CalendarDate.today.adding(days: 30).date)
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          HStack {
            TextField("Name (required)", text: $name)
              .focused($focusedField, equals: .name)
            
            if name.isEmpty {
              Button(action: onAutoFillName) {
                Image(systemName: "wand.and.stars")
              }
              
            } else {
              Button(action: { name = "" }) {
                Image(systemName: "xmark.circle")
              }
            }
          }
          
          HStack {
            TextEditor(text: $notes)
              .foregroundColor(
                notes == notesPlaceholder ? .placeholder : .primary
              )
              .onTapGesture {
                notes == notesPlaceholder ? notes = "" : ()
              }
              .focused($focusedField, equals: .notes)
            
            if !notes.isEmpty && notes != notesPlaceholder {
              Button(action: { notes = "" }) {
                Image(systemName: "xmark.circle")
              }
            }
          }
          .padding(.leading, -4)
          
          HStack {
            TextField("Total amount (required)", value: $amount, format: .number)
              .keyboardType(.numberPad)
              .focused($focusedField, equals: .amount)
            
            if amount != nil {
              Button(action: { amount = nil }) {
                Image(systemName: "xmark.circle")
              }
            }
          }
          
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
          Text("Info")
        } footer: {
          Text("Provide a total amount available for the entire budget period. A daily budget is allocated based on this total amount.")
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
          notes = (budget.notes.isEmpty)
            ? notesPlaceholder : budget.notes
          amount = budget.amount
          startDate = budget.startDate
          endDate = budget.endDate
          
        } else {
          focusedField = .name
        }
      }
      
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .interactiveDismissDisabled(isChanged)
      
      .toolbar {
        ToolbarItem {
          Button(action: onSaveTapped, label: {
            Text("Save")
          })
          .disabled(isSaveDisabled)
        }
        
        if isChanged {
          ToolbarItem(placement: .navigation, content: {
            Button(action: onCancelTapped) { Text("Cancel") }
          })
        }
        
        // TODO: Restore
//        if let focusedField {
//          ToolbarItemGroup(placement: .keyboard) {
//            Spacer()
//            
//            switch focusedField {
//            case .name:
//              Button(action: { self.focusedField = .notes }) {
//                Image(systemName: "arrow.forward")
//              }
//            case .notes: {
//              Button(action: { self.focusedField = .name }) {
//                Image(systemName: "arrow.backward")
//              }
//              Button(action: { self.focusedField = .amount }) {
//                Image(systemName: "arrow.forward")
//              }
//            }
//            case .amount:
//              Button(action: { self.focusedField = .notes }) {
//                Image(systemName: "arrow.backward")
//              }
//            }
//            
//            Button(action: { self.focusedField = nil }) {
//              Image(systemName: "checkmark")
//            }
//          }
//        }
      }
      
      .onChange(of: focusedField) { _, newValue in
        if newValue != .notes, notes == "" {
          notes = notesPlaceholder
        }
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
      // Edit existing:
      budget.name = name
      if notes != notesPlaceholder {
        budget.notes = notes
      }
      budget.amount = amount ?? 0
      budget.startDate = startDate
      budget.endDate = endDate
    case .some(.none):
      // Create new
      let newBudget = BudgetModel(
        name: name,
        notes: (notes == notesPlaceholder) ? "" : notes,
        amount: amount ?? 0,
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
  
  func onCancelTapped() {
    // Setting the binding to nil dismisses the sheet
    budget = nil
  }
  
  func onAutoFillName() {
    name = getDefaultName()
  }
  
  func getDefaultName() -> String {
    currentDate.date.formatted(.dateTime.month(.wide).year(.twoDigits))
    + " Daily Budget"
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
    startDate.calendarDate > currentDate
    || endDate.calendarDate < currentDate
  }
  
  var isAmountInvalid: Bool {
    (amount ?? 0) <= 0
  }
}

#Preview {
  EditBudget(budget: .constant(.some(nil)))
  .modelContainer(for: BudgetModel.self)
}
