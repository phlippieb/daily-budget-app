import SwiftUI

struct AmountText: View {
  let amount: Double
  var wholePartFont: Font = .body
  var fractionPartFont: Font = .body
  
  private var wholePart: Int {
    Int(amount)
  }
  
  private var fractionPart: String {
    String(
      // Show 2 decimal places
      format: "%02d",
      // Take first two decimal digits
      abs(Int(amount.truncatingRemainder(dividingBy: 1) * 100))
    )
  }
  
  var body: some View {
    HStack(alignment: .lastTextBaseline, spacing: 0) {
      Text("\(wholePart)").font(wholePartFont)
      Text(".")
      Text(fractionPart).font(fractionPartFont)
    }
  }
}

#Preview {
  List {
    AmountText(amount: 1.1)
    AmountText(amount: 1)
    AmountText(amount: 2.345)
  }
}
