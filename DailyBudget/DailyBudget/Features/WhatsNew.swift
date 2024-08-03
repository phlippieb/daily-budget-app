import SwiftUI

struct WhatsNew: View {
  @EnvironmentObject private var whatsNew: WhatsNewController
  
  var body: some View {
    VStack(alignment: .leading) {
      Spacer(minLength: 8)
      HStack(alignment: .lastTextBaseline) {
          Text("New in version 1.4")
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
      
      Text("Saving tips")
        .font(.headline)
      
      Text("")
      Text("See saving tips for your active budgets! These tips are based on your current status — if you're under budget, they'll tell you how much you can save for tomorrow; and if you're over budget, they'll tell you how many days it'll take to get back on track.")
      
      ZStack {
        Tip(tip: .breakEven(days: 2))
        .padding()
        .background()
        .overlay(Color.systemBackground.opacity(0.4))
        .cornerRadius(10)
        .shadow(radius: 10)
        .rotationEffect(.degrees(-10))
        .offset(x: 90, y: 70)
        .scaleEffect(0.8)
        
        Tip(tip: .availableTomorrow(amount: 255))
        .padding()
        .background()
        .overlay(Color.systemBackground.opacity(0.3))
        .cornerRadius(10)
        .shadow(radius: 10)
        .rotationEffect(.degrees(10))
        .offset(x: -90, y: 20)
        .scaleEffect(0.8)
      }
      
      Spacer(minLength: 80)
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
