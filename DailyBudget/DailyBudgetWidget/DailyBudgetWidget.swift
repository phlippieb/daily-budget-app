//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(
      date: Date(), emoji: "😀",
      dateText: "Day 1 of 30")
  }
  
  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(
      date: Date(), emoji: "😀",
      dateText: "Day 1 of 30"
    )
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    var entries: [SimpleEntry] = []
    
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(
        date: entryDate, emoji: "😀",
        dateText: "Day 1 of 30")
      entries.append(entry)
    }
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let emoji: String
  
  // MARK: My dummy data
  let dateText: String
}

struct DailyBudgetWidget: Widget {
  let kind: String = "DailyBudgetWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      DailyBudgetWidgetView2(entry: entry)
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
      // TODO: Unconstant
      HStack(alignment: .lastTextBaseline, spacing: 0) {
        Text("1")
          .font(.system(
            size: UIFont.preferredFont(
              forTextStyle: .largeTitle).pointSize * 2))
          .minimumScaleFactor(0.1)
        Text(".80")
      }
      .bold()
      .foregroundStyle(.green)
      
      Text("Available today")
        .fontWeight(.light)
      
      // TODO: Unconstant
      Text("July daily budget")
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
      // TODO: Unconstant
      
      HStack {
        Text("July daily budget")
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
          // TODO: Unconstant
          HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text("1288")
              .font(.system(
                size: UIFont.preferredFont(
                  forTextStyle: .largeTitle).pointSize * 2))
              .minimumScaleFactor(0.1)
            Text(".80")
          }
          .bold()
          .foregroundStyle(.green)
          
          Text("")
          
          // TODO: Unconstant
          HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text("300")
              .font(.system(
                size: UIFont.preferredFont(
                  forTextStyle: .largeTitle).pointSize))
              .minimumScaleFactor(0.1)
            Text(".80")
          }
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
      
      
//      HStack(alignment: .lastTextBaseline) {
//        VStack {
//          
//          
//        }
//        
//        Divider().frame(width: 1)
//        
//        VStack {
//          
//          
//        }
//      }
    }
  }
}

#Preview(as: .systemMedium) {
  DailyBudgetWidget()
} timeline: {
  SimpleEntry(date: .now, emoji: "😀",
              dateText: "Day 1 of 30")
  SimpleEntry(date: .now, emoji: "🤩",
              dateText: "Day 1 of 30")
}
