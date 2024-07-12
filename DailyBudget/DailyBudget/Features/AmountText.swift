import SwiftUI

struct AmountText: View {
  let amount: Double
  var wholePartFont: Font = .body
  var fractionPartFont: Font = .body
  
  var body: some View {
    HStack(alignment: .lastTextBaseline, spacing: 0) {
      Text("\(amount.wholePart)")
        .font(wholePartFont)
        .contentTransition(.numericText(value: Double(amount.wholePart)))
      
      Text(".")
      
      Text(amount.fractionPartString)
        .font(fractionPartFont)
        .contentTransition(.numericText(value: Double(amount.fractionPart)))
    }
  }
}

#Preview {
  List {
    AmountText(amount: 123.456, wholePartFont: .largeTitle, fractionPartFont: .body)
    AmountText(amount: 1.1)
    AmountText(amount: 1)
    AmountText(amount: 2.345)
  }
}
