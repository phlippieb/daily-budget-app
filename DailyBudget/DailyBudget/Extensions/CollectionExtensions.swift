extension Collection {
  var nonEmpty: Self? {
    count == 0 ? nil : self
  }
}

extension Collection where Self.Index == Int {
  func item(at index: Int) -> Element? {
    index < count ? self[index] : nil
  }
}
