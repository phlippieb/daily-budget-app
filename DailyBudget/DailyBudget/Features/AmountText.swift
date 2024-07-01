import SwiftUI

struct AmountText: View {
  let amount: Double
  var wholePartFont: Font = .body
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
