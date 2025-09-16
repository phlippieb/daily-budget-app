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
      Text("Decimal editing").font(.headline)
      Text("A much-needed update! You can now edit the amounts for budgets and expenses to two decimal places.")
      
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
