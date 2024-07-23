import SwiftUI

struct WhatsNew: View {
  @EnvironmentObject private var whatsNew: WhatsNewController
  
  var body: some View {
    VStack(alignment: .leading) {
      Spacer(minLength: 8)
      HStack(alignment: .lastTextBaseline) {
          Text("New in version 1.3")
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
      
      Text("Widgets")
        .font(.headline)
      
      Text("")
      Text("You can now add widgets to your home screen to see your daily budgeted amount and expenditure at a glance.")
      
      ZStack {
        AvailableAndSpentTodayWidgetView(
          entry: .init(date: Date(), budgetToDisplay: .placeholder)
        )
        .padding()
        .background()
        .overlay(Color.systemBackground.opacity(0.4))
        .cornerRadius(10)
        .shadow(radius: 10)
        .rotationEffect(.degrees(-10))
        .offset(x: 45, y: 30)
        .scaleEffect(0.6)
        
        AvailableTodayWidgetView(
          entry: .init(date: Date(), budgetToDisplay: .placeholder)
        )
        .padding()
        .background()
        .overlay(Color.systemBackground.opacity(0.3))
        .cornerRadius(10)
        .shadow(radius: 10)
        .rotationEffect(.degrees(10))
        .offset(x: -130, y: -40)
        .scaleEffect(0.6)
      }
      
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
