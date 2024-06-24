import SwiftUI

/// An observable object wrapping the current date, which can be read from the environment
class CurrentDate: ObservableObject {
  @Published var value = Date.now
}
