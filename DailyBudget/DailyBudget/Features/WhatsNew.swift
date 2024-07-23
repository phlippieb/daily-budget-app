import SwiftUI

struct WhatsNew: View {
  @EnvironmentObject private var whatsNew: WhatsNewObservableObject
  
  var body: some View {
    VStack(alignment: .leading) {

      
      HStack(alignment: .lastTextBaseline) {
//        Spacer()
        
        Group {
          Text("New in version 1.3")
          Image(systemName: "sparkles")
        }
          .foregroundStyle(LinearGradient(
            stops: [
              .init(color: .green, location: 0),
              .init(color: .blue, location: 0.5),
              .init(color: .purple, location: 1)
            ], startPoint: .leading, endPoint: .trailing)
          )
      }
      .font(.subheadline)
      
      Text("Widgets")
        .font(.headline)
      
//      Text("")
//      Text("Daily Budget now has widgets!")
      
      Text("")
      Text("You can now add a widget to your home screen to see your daily budgeted amount and expenditure at a glance.")
      
      HStack {
        Spacer()
        Button {
          withAnimation(.bouncy) {
            whatsNew.markAsSeen()
          }
        } label: {
          Text("Dismiss")
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
  }
}
