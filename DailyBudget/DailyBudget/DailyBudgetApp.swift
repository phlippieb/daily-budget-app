import SwiftUI

@main
struct DailyBudgetApp: App {
  private var currentDate = CurrentDate()
  
  @AppStorage("appearance_preference") private var appearancePreference: Int = 0
  private var preferredColorScheme: ColorScheme? {
    switch appearancePreference {
    case 1: return .light
    case 2: return .dark
    default: return .none
    }
  }
  
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
        .preferredColorScheme(preferredColorScheme)
    }
  }
}

