import SwiftUI

struct WhatsNew: View {
//  @Binding var showingWhatsNew: Bool
  var onHide: () -> Void
  
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
//        showingWhatsNew.toggle()
        onHide()
      } label: {
        Text("Got it")
      }
      .padding()
    }
  }
}

//extension View {
//  func whatsNew() -> some View {
//    modifier(WhatsNewAlert())
//  }
//}
//
//struct WhatsNewAlert: ViewModifier {
//  @EnvironmentObject var service: WhatsNewService
//  @State private var alertIsPresented = true
//  
//  func body(content: Content) -> some View {
//    content.alert(
//      "What's new",
//      isPresented: $alertIsPresented,
//      actions: {
//        Button("Got it") {
//          alertIsPresented = false
//        }
//      }, message: {
//        Text(service.messageToDisplay ?? "")
//      })
////      Alert(
////        title: "What's new",
////        message: service.messageToDisplay,
////        dismissButton: .default("Got it", action: {
////          service.markMessageAsDisplayed()
////        }))
//      
//    
//  }
//}

class WhatsNewService: ObservableObject {
  // TODO: create a solution that:
  // (1) only shows the message to returning users on a new version
  // (2) doesn't show the message every time the app is launched

  // MARK: Interface
  
  var messageToDisplay: String? {
    message
  }
  
  func markMessageAsDisplayed() {
    message = nil
  }
  
  // MARK: State
  
  private var message: String? = """
    Daily Budget now has widgets! Long-press the home screen and search for "daily budget" to find and add a widget to your home screen.
    """
}
