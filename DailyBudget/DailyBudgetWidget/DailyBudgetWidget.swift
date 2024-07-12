import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: View -

struct DailyBudgetWidget: Widget {
  let kind: String = "DailyBudgetWidget"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SelectBudgetIntent.self,
      provider: DailyBudgetWidgetTimelineProvider()) { entry in
        DailyBudgetWidgetView1(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
          .modelContainer(for: BudgetModel.self)
      }
      .configurationDisplayName("My Widget")
      .description("This is an example widget.")
  }
}

struct DailyBudgetWidgetView1: View {
  var entry: BudgetEntry
  
  @Query var budgets: [BudgetModel]
  
  var body: some View {
    if let details = entry.details {
      VStack(alignment: .center) {
        AmountText(
          amount: details.available,
          wholePartFont: .system(
            size: UIFont.preferredFont(
              forTextStyle: .largeTitle).pointSize * 2)
        )
        .minimumScaleFactor(0.1)
        .bold()
        .foregroundStyle(.green)
        
        Text("Available today")
          .fontWeight(.light)
        
        Text(details.title)
          .font(.subheadline)
          .bold()
          .lineLimit(2)
          .multilineTextAlignment(.center)
      }
    } else {
      Text("Long press and select a budget")
    }
  }
}

// TODO: Include
//struct DailyBudgetWidgetView2: View {
//  var entry: BudgetEntry
//  
//  var body: some View {
//    VStack {
//      HStack {
//        Text(entry.title)
//          .font(.subheadline)
//          .bold()
//          .lineLimit(2)
//          .multilineTextAlignment(.center)
//        Spacer()
//        Image(systemName: "calendar")
//        Text(entry.dateText)
//      }
//      .font(.footnote)
//      
//      Spacer()
//      
//      Grid {
//        GridRow(alignment: .lastTextBaseline) {
//          AmountText(
//            amount: entry.available,
//            wholePartFont: .system(
//              size: UIFont.preferredFont(
//                forTextStyle: .largeTitle).pointSize * 2)
//          )
//          .minimumScaleFactor(0.1)
//          .bold()
//          .foregroundStyle(.green)
//          
//          Text("")
//          
//          AmountText(
//            amount: entry.spent,
//            wholePartFont: .system(
//              size: UIFont.preferredFont(
//                forTextStyle: .largeTitle).pointSize)
//          )
//          .minimumScaleFactor(0.1)
//          .bold()
//        }
//        
//        GridRow(alignment: .lastTextBaseline) {
//          Text("Available today")
//            .fontWeight(.light)
//          
//          Text("")
//          
//          Text("Spent")
//            .fontWeight(.light)
//        }
//      }
//    }
//  }
//}

// MARK: Entry -

// MARK: Provider -

// MARK: Double extension -
// TODO: Refactor

extension Double {
  var wholePart: Int {
    Int(self)
  }
  
  var fractionPart: String {
    String(
      // Show 2 decimal places
      format: "%02d",
      // Take first two decimal digits
      abs(Int(self.truncatingRemainder(dividingBy: 1) * 100))
    )
  }
}

// MARK: Amount label -
// TODO: Refactor if not too different from main?

struct AmountText: View {
  let amount: Double
  var wholePartFont: Font = .body
  var fractionPartFont: Font = .body
  
  var body: some View {
    HStack(alignment: .lastTextBaseline, spacing: 0) {
      Text("\(amount.wholePart)").font(wholePartFont)
      Text(".")
      Text(amount.fractionPart).font(fractionPartFont)
    }
  }
}

#Preview(as: .systemMedium) {
  DailyBudgetWidget()
} timeline: {
  BudgetEntry(date: .now, details: nil)
  
  BudgetEntry(
    date: .now,
    details: .init(
      title: "July daily budget",
      dateText: "Day 1 of 30",
      available: 1288.99,
      spent: 300.88))
  
  BudgetEntry(
    date: .now,
    details: .init(
      title: "July daily budget",
      dateText: "Day 1 of 30",
      available: 4.22,
      spent: 555.88))
}

