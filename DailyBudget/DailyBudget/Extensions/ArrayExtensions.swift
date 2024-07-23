extension Array {
  func item(at index: Int) -> Element? {
    index < count ? self[index] : nil
  }
}

extension Array where Element: Identifiable {
  mutating func remove(_ element: Element) {
    removeAll(where: { $0.id == element.id })
  }
}
