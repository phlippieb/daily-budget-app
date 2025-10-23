import SwiftUI

struct AppInfo: View {
  @EnvironmentObject private var whatsNew: WhatsNewController
  
  var body: some View {
    if #available(iOS 26, *) {
      getBody()
        .glassEffect()
        .glassEffectTransition(.materialize)
    } else {
      getBody()
        .background(Material.regular)
        .transition(.offset(CGSize(width: 0, height: 150)))
        .cornerRadius(20)
        .padding()
    }
  }
  
  private func getBody() -> AnyView {
    AnyView(
      VStack {
        Link(
          destination: URL(string: "https://dailybudget.phlippieb.dev/")!
        ) {
          HStack {
            Text("Daily Budget")
            Image(systemName: "safari")
          }
        }
        
        if let appVersion = AppVersion() {
          Text("Version \(appVersion.stringValue)")
            .foregroundStyle(.gray)
          
          if !whatsNew.shouldDisplay {
            Button {
              withAnimation {
                whatsNew.markAsSeen(false, for: .widgets)
              }
            } label: {
              Image(systemName: "sparkles").frame(height: 16)
            }
          }
        }
      }
      .padding()
    )
  }
}

#Preview {
  AppInfo()
    .environmentObject(WhatsNewController())
}
