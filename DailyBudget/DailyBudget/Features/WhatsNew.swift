import SwiftUI

struct WhatsNew: View {
  @EnvironmentObject private var whatsNew: WhatsNewObservableObject
  
  var body: some View {
    VStack(alignment: .center) {
      HStack(alignment: .top) {
        Image(systemName: "sparkles")
        Text("New in version 1.3: Widgets")
          .font(.headline)
      }
      .padding()
      
      Text("Daily Budget now has widgets!\nAdd a widget to your home screen and see your daily budgeted amount and expenditure at a glance.")
        .font(.subheadline)
      
      Button {
        withAnimation(.bouncy) {
          whatsNew.markAsSeen()
        }
      } label: {
        Text("Dismiss")
      }
      .padding()
    }
  }
}

#Preview {
  List {
    WhatsNew()
  }
}
