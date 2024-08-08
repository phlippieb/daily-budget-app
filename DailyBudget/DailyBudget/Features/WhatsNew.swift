import SwiftUI

struct WhatsNew: View {
  @EnvironmentObject private var whatsNew: WhatsNewController
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .lastTextBaseline) {
        Text("New in version \(NotableUpdate.latest.version)")
          Image(systemName: "sparkles")
      }
      .font(.subheadline)
      .foregroundStyle(LinearGradient(
        stops: [
          .init(color: .green, location: 0),
          .init(color: .blue, location: 0.5),
          .init(color: .purple, location: 1)
        ], startPoint: .leading, endPoint: .trailing)
      )
      
      
      Text("")
      Text("New widget: Spent Today").font(.headline)
      Text("Designed to complement the \"Available Today\" widget, the new \"Spent Today\" widget shows you your total expenses for the day. Pro tip: combine these widgets in a stack!")
      
      SpentTodayWidgetView(entry: .init(date: .now, budgetToDisplay: .placeholder))
        .padding()
        .background()
        .overlay(Color.systemBackground.opacity(0.4))
        .cornerRadius(10)
        .shadow(radius: 10)
        .scaleEffect(0.8)
      
      
      Text("")
      Text("Saving tips").font(.headline)
      Text("See saving tips for your active budgets! These tips are based on your current status — if you're under budget, they'll tell you how much you can save for tomorrow; and if you're over budget, they'll tell you how many days it'll take to get back on track.")
      
      Tip(tip: .availableTomorrow(amount: 99))
      .padding()
      .background()
      .overlay(Color.systemBackground.opacity(0.4))
      .cornerRadius(10)
      .shadow(radius: 10)
      .scaleEffect(0.8)
      
      Tip(tip: .breakEven(days: 2))
      .padding()
      .background()
      .overlay(Color.systemBackground.opacity(0.4))
      .cornerRadius(10)
      .shadow(radius: 10)
      .scaleEffect(0.8)
      
      Text("")
      Text("Improved editing screens").font(.headline)
      Text("Creating and editing your budgets and expenses is just a little nicer now.")
      Text("- Jump between text fields by using the arrows in the keyboard toolbar")
      Text("- Toggle the quick entry setting while editing an expense to add another immediately after saving")
      Text("- You can no longer pull down to dismiss if you changes, meaning you won't accidentally delete your hard work")
      
      Text("")
      Text("Tapping on a widget now takes you to the corresponding budget")
        .font(.headline)
      Text("A small but important update. If you had the app open and are viewing a specific budget, and then tap on a widget set to track another budget, the app will now navigate to the budget for the widget you tapped on.")
      
      Text("")
      Text("Start app on only active budget").font(.headline)
      Text("Another small but nice update. If you only have one active budget, the app will open to that budget. You can always navigate back to the list of all budgets from there.")
      
      HStack {
        Spacer()
        Button {
          withAnimation(.bouncy) {
            whatsNew.markAsSeen()
          }
        } label: {
          Text("Got it")
        }
        Spacer()
      }
      .padding()
    }
    
    .overlay(
      RoundedRectangle(
        cornerRadius: 10,
        style: .circular
      )
      .stroke(Gradient(colors: [.green, .blue, .purple]))
      .containerRelativeFrame([.horizontal, .vertical]) { length, _ in
        length-1
      }
    )
  }
}

#Preview {
  List {
    WhatsNew()
      .modelContainer(for: BudgetModel.self)
  }
}
