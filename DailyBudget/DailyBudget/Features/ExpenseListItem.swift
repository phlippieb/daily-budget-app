import SwiftUI

struct ExpenseListItem: View {
  @State var item: Expense
  
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
  ExpenseListItem(item: Expense(
    name: "Food", amount: 199, date: .now))
}
