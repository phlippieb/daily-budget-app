import SwiftUI
import SwiftData

struct ViewBudget: View {
  @State var budget: BudgetModel
  
  @EnvironmentObject private var currentDate: CurrentDate
  
  private var info: BudgetProgressInfo {
    .init(budget: budget, date: currentDate.value.calendarDate)
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .listRowSeparatorLeading) {
        Text("Today").font(.title)
        Today(info: info)
        
        Text("Budget info").font(.title)
          .padding(.init(top: 20, leading: 0, bottom: 0, trailing: 0))
        BudgetInfo(budget: budget)
        
        Text("Recent expenses").font(.title)
          .padding(.init(top: 20, leading: 0, bottom: 0, trailing: 0))
        RecentExpenses(expenses: budget.expenses ?? [])
      }
      .padding(.horizontal, 24)
    }
    .navigationTitle(info.budget.name)
    .navigationBarTitleDisplayMode(.inline)
  }
}

private struct Today: View {
  let info: BudgetProgressInfo
  
  private var accentColor: Color {
    info.currentAllowance < 0 ? .red : .green
  }
  
  private var status: String? {
    if info.budget.totalExpenses >= info.budget.amount {
      return "Entire budget depleted"
    } else if info.isActive, info.currentAllowance <= 0 {
      return "Daily allowance depleted"
    } else {
      return nil
    }
  }
  
  private let cornerRadius: CGFloat = 10
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "calendar")
        Text("Day \(info.dayOfBudget) of \(info.budget.totalDays)")
        
        if let status {
          Spacer()
          Image(systemName: "flag")
            .foregroundStyle(.red)
          Text(status)
        }
      }
      .font(.footnote)
      
      
      Text("")
      Text("Available")
      HStack(alignment: .lastTextBaseline, spacing: 0) {
        AmountText(amount: info.currentAllowance).bold()
        Text(" of ")
        AmountText(
          amount: info.budget.dailyAmount,
          wholePartFont: .body)
        // TODO: ^^ what makes the most sense to display here, and below?
      }
      
      Divider()
      
      Text("")
      Text("Spent")
      HStack(alignment: .lastTextBaseline, spacing: 0) {
        // TODO: Get only amount spent today
        AmountText(amount: info.budget.totalExpenses)
        Text(" of ")
        AmountText(
          amount: info.budget.dailyAmount,
          wholePartFont: .body)
      }
    }
    .padding()
    .background(Material.thick)
    .background(Gradient(colors: [.secondary, .secondary, accentColor]).opacity(0.5))
//    .background(Color.secondary)
    .cornerRadius(cornerRadius)
    .overlay(
      RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(Gradient(colors: [.gray.opacity(0.2), accentColor.opacity(0.9)]), lineWidth: 1)
    )
    .shadow(color: .gray.opacity(0.3), radius: 20)
  }
}

private struct AmountText: View {
  let amount: Double
  var wholePartFont: Font = .largeTitle
  var fractionPartFont: Font = .body
  
  private var wholePart: Int {
    Int(amount)
  }
  
  private var fractionPart: String {
    String(abs(Int(amount.truncatingRemainder(dividingBy: 1) * 100)))
  }
  
  var body: some View {
    HStack(alignment: .lastTextBaseline, spacing: 0) {
      Text("\(wholePart)").font(wholePartFont)
      Text(".")
      // TODO: Show as "00", not "0" for 0
      Text(fractionPart).font(fractionPartFont)
    }
  }
}

private struct BudgetInfo: View {
  let budget: BudgetModel
  
  var body: some View {
    VStack {
      LabeledContent {
        Text(
          budget.startDate.calendarDate.toStandardFormatting()
          + " - "
          + budget.endDate.calendarDate.toStandardFormatting()
        )
      } label: {
        Text("Period")
      }
      
      Divider()
      LabeledContent {
        Text("\(budget.amount, specifier: "%.2f")")
      } label: {
        Text("Total budget")
      }
      
      Divider()
      LabeledContent {
        Text("\(budget.totalExpenses, specifier: "%.2f")")
      } label: {
        Text("Total spent")
      }
      
      Divider()
      LabeledContent {
        Text("\(budget.dailyAmount, specifier: "%.2f")")
      } label: {
        Text("Daily budget")
      }
    }
    .padding()
//    .background(.white)
//    .background(Color.primary.colorInvert())
    .background(Material.regular)
    .cornerRadius(8)
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(.primary, lineWidth: 0.1)
    )
    .shadow(color: .gray.opacity(0.3), radius: 20)
  }
}

private struct RecentExpenses: View {
  let expenses: [ExpenseModel]
  
  var body: some View {
//    List {
      if expenses.isEmpty {
        HStack {
          Text("No expenses")
            .foregroundStyle(.gray)
          Spacer()
        }
        .padding(.vertical, 2)
        
      } else {
        ForEach(
          expenses
            .sorted(by: {$0.day > $1.day})
            .suffix(3)
        ) { expense in
          Button(
            // TODO: implement
            action: { }//onEditExpense(expense) }
          ) {
            VStack {
              ExpenseListItem(item: expense)
              Divider()
            }
            .contentShape(Rectangle())
          }
          .buttonStyle(PlainButtonStyle())
        }
        
        // TODO: Implement
        //      NavigationLink(
        //        destination: ViewExpenses(budget: $budget)
        //      ) {
        //        Text("View all")
        //      }
//        .padding()
      }
//    }
//    .listStyle(.plain)
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  let budget = BudgetModel(
    name: "My budget",
    amount: 10000,
    firstDay: .today.adding(days: -1),
    lastDay: .today.adding(days: 30),
    expenses: [])
  container.mainContext.insert(budget)
  
  let expenses = [
    ExpenseModel(
      name: "Expense",
      amount: 1000,
      day: CalendarDate.today),
    ExpenseModel(
      name: "Expense2",
      amount: 10,
      day: CalendarDate.today.adding(days: -1)),
    ExpenseModel(
      name: "Expense 3",
      amount: 10,
      day: CalendarDate.today.adding(days: -1))
  ]
  expenses.forEach {
    container.mainContext.insert($0)
  }
  budget.expenses = expenses
  
  return NavigationView {
    ViewBudget(budget: budget)
  }
  .modelContainer(container)
  .environmentObject(CurrentDate())
}
