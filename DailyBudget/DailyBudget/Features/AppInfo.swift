import SwiftUI

struct AppInfo: View {
  @EnvironmentObject private var whatsNew: WhatsNewObservableObject
  
  var body: some View {
    VStack {
      Link(destination: URL(string: "https://phlippieb.github.io/daily-budget-app/")!) {
        HStack {
          Text("Daily Budget")
          Image(systemName: "safari")
        }
      }
      if let appVersion = AppVersion() {
        Text("Version \(appVersion.stringValue)")
          .foregroundStyle(.gray)
        
        if
          appVersion == whatsNew.latestVersionWithNewMessage,
          !whatsNew.shouldDisplay
        {
          Button {
            withAnimation {
              whatsNew.markAsSeen(false)              
            }
          } label: {
            Image(systemName: "sparkles").frame(height: 16)
          }
        }
      }
    }
    .padding()
    .background(Material.regular)
    .transition(.offset(CGSize(width: 0, height: 150)))
    .cornerRadius(20)
    .padding()
  }
}

#Preview {
  AppInfo()
    .environmentObject(WhatsNewObservableObject())
}
