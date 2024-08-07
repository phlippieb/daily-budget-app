import SwiftUI

struct AppInfo: View {
  @EnvironmentObject private var whatsNew: WhatsNewController
  
  var body: some View {
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
    .background(Material.regular)
    .transition(.offset(CGSize(width: 0, height: 150)))
    .cornerRadius(20)
    .padding()
  }
}

#Preview {
  AppInfo()
    .environmentObject(WhatsNewController())
}
