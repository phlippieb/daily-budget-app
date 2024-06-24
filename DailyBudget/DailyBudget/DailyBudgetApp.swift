import SwiftUI

@main
struct DailyBudgetApp: App {
  var body: some Scene {
    WindowGroup {
      Home()
        .modelContainer(for: BudgetModel.self)
        .environmentObject(CurrentDate())
    }
  }
}
