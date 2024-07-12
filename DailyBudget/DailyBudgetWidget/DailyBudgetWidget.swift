import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// TODO: Ensure i didn't mess up the migration - install from app store, then from test flight

// TODO: Fix this warning:
// The CFBundleVersion of an app extension ('1') must match that of its containing parent app ('0').

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
      .configurationDisplayName("Available amount")
      .description("Shows your daily available amount for a chosen budget.")
  }
}

struct DailyBudgetWidgetView1: View {
  var entry: BudgetEntry
  
  @Query private var budgets: [BudgetModel]
  
  private var info: BudgetProgressInfo? {
    guard
      let id = entry.entity?.id,
      let budget = budgets.first(where: { $0.uuid == id })
    else { return nil }
    
    return BudgetProgressInfo(budget: budget, date: .today)
  }
  
  var body: some View {
    if let info {
      VStack(alignment: .center) {
        AmountText(
          amount: info.currentAllowance,
          wholePartFont: .system(
            size: UIFont.preferredFont(
              forTextStyle: .largeTitle).pointSize * 2)
        )
        .minimumScaleFactor(0.1)
        .bold()
        .foregroundStyle(.green)
        
        Text("Available today")
          .fontWeight(.light)
        
        Text(info.budget.name)
          .font(.subheadline)
          .bold()
          .lineLimit(2)
          .multilineTextAlignment(.center)
      }
      
    } else {
      Text("No budget selected").foregroundStyle(.gray)
      Text("Long-press to configure")
        .font(.footnote)
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
  
  var fractionPartInt: Int {
    // Take first two decimal digits
    abs(Int(self.truncatingRemainder(dividingBy: 1) * 100))
  }
  
  var fractionPart: String {
    String(
      // Show 2 decimal places
      format: "%02d",
      fractionPartInt
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
      Text("\(amount.wholePart)")
        .font(wholePartFont)
        .contentTransition(.numericText(value: Double(amount.wholePart)))
      
      Text(".").font(fractionPartFont)
      
      Text(amount.fractionPart)
        .font(fractionPartFont)
        .contentTransition(.numericText(value: Double(amount.fractionPartInt)))
    }
  }
}

// TODO: Find a way to build a preview
//#Preview(as: .systemMedium) {
//  DailyBudgetWidget()
//} timeline: {
//  BudgetEntry(date: .now, details: nil)
//  
//  BudgetEntry(
//    date: .now,
//    details: .init(
//      title: "July daily budget",
//      dateText: "Day 1 of 30",
//      available: 1288.99,
//      spent: 300.88))
//  
//  BudgetEntry(
//    date: .now,
//    details: .init(
//      title: "July daily budget",
//      dateText: "Day 1 of 30",
//      available: 4.22,
//      spent: 555.88))
//}
//
