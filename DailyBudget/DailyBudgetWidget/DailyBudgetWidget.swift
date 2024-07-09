import WidgetKit
import SwiftUI

// MARK: View -

struct DailyBudgetWidget: Widget {
  let kind: String = "DailyBudgetWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      DailyBudgetWidgetView1(entry: entry)
      .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}

struct DailyBudgetWidgetView1: View {
  var entry: Provider.Entry
  
  var body: some View {
    VStack(alignment: .center) {
      AmountText(
        amount: entry.available,
        wholePartFont: .system(
          size: UIFont.preferredFont(
            forTextStyle: .largeTitle).pointSize * 2)
      )
      .minimumScaleFactor(0.1)
      .bold()
      .foregroundStyle(.green)
      
      Text("Available today")
        .fontWeight(.light)
      
      Text(entry.title)
        .font(.subheadline)
        .bold()
        .lineLimit(2)
        .multilineTextAlignment(.center)
    }
  }
}

struct DailyBudgetWidgetView2: View {
  var entry: Provider.Entry
  
  var body: some View {
    VStack {
      HStack {
        Text(entry.title)
          .font(.subheadline)
          .bold()
          .lineLimit(2)
          .multilineTextAlignment(.center)
        Spacer()
        Image(systemName: "calendar")
        Text(entry.dateText)
      }
      .font(.footnote)
      
      Spacer()
      
      Grid {
        GridRow(alignment: .lastTextBaseline) {
          AmountText(
            amount: entry.available,
            wholePartFont: .system(
              size: UIFont.preferredFont(
                forTextStyle: .largeTitle).pointSize * 2)
          )
          .minimumScaleFactor(0.1)
          .bold()
          .foregroundStyle(.green)
          
          Text("")
          
          AmountText(
            amount: entry.spent,
            wholePartFont: .system(
              size: UIFont.preferredFont(
                forTextStyle: .largeTitle).pointSize)
          )
          .minimumScaleFactor(0.1)
          .bold()
        }
        
        GridRow(alignment: .lastTextBaseline) {
          Text("Available today")
            .fontWeight(.light)
          
          Text("")
          
          Text("Spent")
            .fontWeight(.light)
        }
      }
    }
  }
}

// MARK: Entry -

struct BudgetEntry: TimelineEntry {
  var date: Date
  
  let title: String
  let dateText: String
  let available: Double
  let spent: Double
}

// MARK: Provider -

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> BudgetEntry {
    BudgetEntry(
      date: Date(),
      title: "My daily budget",
      dateText: "Day 1 of 31",
      available: 99,
      spent: 1)
  }
  
  func getSnapshot(
    in context: Context, completion: @escaping (BudgetEntry) -> ()
  ) {
    completion(BudgetEntry(
      date: Date(),
      title: "My daily budget",
      dateText: "Day 1 of 31",
      available: 99,
      spent: 1))
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetEntry>) -> ()) {
    var entries: [BudgetEntry] = []
    
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//    let currentDate = Date()
//    for hourOffset in 0 ..< 5 {
//      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//      let entry = SimpleEntry(
//        date: entryDate, emoji: "😀",
//        dateText: "Day 1 of 30")
//      entries.append(entry)
//    }
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

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

#Preview {
  List {
    AmountText(amount: 123.456, wholePartFont: .largeTitle, fractionPartFont: .body)
    AmountText(amount: 1.1)
    AmountText(amount: 1)
    AmountText(amount: 2.345)
  }
}



#Preview(as: .systemMedium) {
  DailyBudgetWidget()
} timeline: {
  BudgetEntry(
    date: .now,
    title: "July daily budget",
    dateText: "Day 1 of 30",
    available: 1288.99,
    spent: 300.88)
  
  BudgetEntry(
    date: .now,
    title: "July daily budget",
    dateText: "Day 1 of 30",
    available: 4.22,
    spent: 555.88)
}

