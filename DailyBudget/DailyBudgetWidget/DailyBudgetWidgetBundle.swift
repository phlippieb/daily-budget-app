//

import WidgetKit
import SwiftUI

@main
struct DailyBudgetWidgetBundle: WidgetBundle {
  var body: some Widget {
    AvailableTodayWidget()
    SpentTodayWidget()
    AvailableAndSpentTodayWidget()
  }
}
