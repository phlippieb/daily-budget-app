import SwiftUI

@main
struct DailyBudgetApp: App {
  var currentDate = CurrentDate()
  
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
    }
  }
}
