import SwiftUI

struct ExpenseListItem: View {
  var item: ExpenseModel
  
  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading) {
        Text(item.name)
        Text(item.date.toStandardFormatting()).font(.footnote)
      }
      Spacer()
      Text("\(item.amount, specifier: "%.2f")")
    }
  }
}

#Preview {
  ExpenseListItem(item: .init(
    name: "Food", amount: 100, date: .today)
  )
  .modelContainer(for: ExpenseModel.self, inMemory: true)
}
