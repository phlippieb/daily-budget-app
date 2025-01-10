// TODO: We also have array extensions; move those here?
extension Collection {
  var nonEmpty: Self? {
    self.count == 0 ? nil : self
  }
}
