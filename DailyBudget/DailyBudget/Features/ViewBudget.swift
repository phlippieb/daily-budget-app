import SwiftUI

struct ViewBudget: View {
  @State var item: BudgetAtDate
  var onDelete: () -> Void = {}
  
  @State private var isEditBudgetShown = false
  
  var body: some View {
    ScrollView {
      // Today's budget summary
      GroupBox {
        Text("Today").font(.title)
        
        HStack {
          Text(item.date.formatted(.dateTime.day().month().year()))
          Image(systemName: "calendar")
          Text("Day \(item.dayOfBudget) / \(item.budget.totalDays)")
        }
        
        Spacer().frame(height: 20)
        
        if item.currentAllowance < 0 {
          Text("Over budget")
          Text("\(item.currentAllowance, specifier: "%.2f")")
            .font(.largeTitle)
            .foregroundStyle(.red)
        } else {
          Text("Available")
          Text("\(item.currentAllowance, specifier: "%.2f")")
            .font(.largeTitle)
            .foregroundStyle(.green)
        }
      }
      
      // Budget info
      Spacer().frame(height: 40)
      Section {
        HStack {
          Text("Budget").font(.title)
          Spacer()
          Button(action: onEditBudgetTapped) {
            Image(systemName: "pencil")
          }
        }
        
        LabeledContent {
          Text(
            item.budget.startDate.toStandardFormatting()
            + " - "
            + item.budget.endDate.toStandardFormatting()
          )
        } label: {
          Text("Period")
        }
        
        LabeledContent {
          Text("\(item.budget.amount, specifier: "%.2f")")
        } label: {
          Text("Total budget")
        }
        
        LabeledContent {
          Text("\(item.budget.totalExpenses, specifier: "%.2f")")
        } label: {
          Text("Total spent")
        }
        
        LabeledContent {
          Text("\(item.budget.dailyAmount, specifier: "%.2f")")
        } label: {
          Text("Daily budget")
        }
      }
      .onTapGesture {
        onEditBudgetTapped()
      }
      
      // Expenses
      Spacer().frame(height: 40)
      Section {
        HStack {
          Text("Expenses").font(.title)
          Spacer()
          Button(action: onAddExpenseTapped) {
            Image(systemName: "plus")
          }
        }
        Spacer().frame(height: 10)
        
        if item.budget.expenses.isEmpty {
          HStack {
            Text("No expenses")
              .foregroundStyle(.gray)
            Spacer()
          }
          .padding(.vertical, 2)
          
        } else {
          ForEach($item.budget.expenses) { expense in
            VStack {
              ExpenseListItem(item: expense.wrappedValue)
              Divider()
            }
          }
          
        }
      }
    }
    .padding()
    
    .navigationTitle(item.budget.name)
    .navigationBarTitleDisplayMode(.inline)
    
    .sheet(isPresented: $isEditBudgetShown) {
      EditBudget(.edit(item.budget), onSave: { budget in
        item.budget = budget
        isEditBudgetShown = false
      }, onDelete: {
        onDelete()
        isEditBudgetShown = false
      })
    }
  }
}

// MARK: Actions
private extension ViewBudget {
  func onEditBudgetTapped() {
    isEditBudgetShown = true
  }
  
  func onAddExpenseTapped() {}
}

#Preview {
  ViewBudget(item: .init(
    budget: .init(
      name: "My budget",
      amount: 5000,
      startDate: .now.addingTimeInterval(-10*24*60*60),
      endDate: .now.addingTimeInterval(10*24*60*60),
      expenses: [
        .init(name: "Food", amount: 20, date: .now),
        .init(name: "Food", amount: 20, date: .now),
        .init(name: "Food", amount: 20, date: .now),
        .init(name: "Food", amount: 20, date: .now),
        .init(name: "Food", amount: 20, date: .now),
        .init(name: "Food", amount: 20, date: .now),
        .init(name: "Food", amount: 20, date: .now)
      ]),
    date: .now))
}
