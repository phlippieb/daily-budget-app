import SwiftUI
import WidgetKit

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
      
      // MARK: Provide What's New controller
        .environmentObject(WhatsNewController())
      
      // MARK: Appearance
        .preferredColorScheme(.init(appearancePreference: appearancePreference))
      
      // MARK: Update widgets when data changes
        .onReceive(NotificationCenter.default.publisher(
          for: Notification.Name.NSManagedObjectContextDidSave
        ), perform: { _ in
          WidgetCenter.shared.reloadAllTimelines()
        })
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
