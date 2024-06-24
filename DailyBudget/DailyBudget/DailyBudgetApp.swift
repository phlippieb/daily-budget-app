import SwiftUI

@main
struct DailyBudgetApp: App {
  private var currentDate = CurrentDate()
  @AppStorage("appearance_preference") private var appearancePreference: Int = 0
  
  var body: some Scene {
    WindowGroup {
      Home()
      
      // MARK: Provide persistent model container
        .modelContainer(for: BudgetModel.self)
        
      // MARK: Provide and update current date
        .environmentObject(currentDate)
        .onReceive(NotificationCenter.default.publisher(
          for: Notification.Name.NSCalendarDayChanged
        )) { _ in
          currentDate.value = .now
        }
      
      // MARK: Appearance
        .preferredColorScheme(.init(appearancePreference: appearancePreference))
    }
  }
}

private extension ColorScheme {
  init?(appearancePreference: Int) {
    switch appearancePreference {
    case 1: self = .light
    case 2: self = .dark
    default: return nil
    }
  }
}
