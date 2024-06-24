import SwiftUI

struct ExpenseListItem: View {
  var item: ExpenseModel
  
  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading) {
        Text(item.name)
        Text(item.day.toStandardFormatting()).font(.footnote)
      }
      Spacer()
      if item.amount < 0 {
        // Income
        Text("+\(item.amount * -1, specifier: "%.2f")")
          .foregroundStyle(.green)
      } else {
        // Expense
        Text("\(item.amount, specifier: "%.2f")")
      }
    }
  }
}

#Preview {
  ExpenseListItem(item: .init(
    name: "Food", amount: 100, day: .today)
  )
  .modelContainer(for: ExpenseModel.self, inMemory: true)
}
