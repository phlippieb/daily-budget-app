extension Double {
  var wholePart: Int {
    Int(self)
  }
  
  var fractionPart: Int {
    abs(Int(self.truncatingRemainder(dividingBy: 1) * 100))
  }
  
  var fractionPartString: String {
    String(
      // Show 2 decimal places
      format: "%02d",
      // Take first two decimal digits
      fractionPart
    )
  }
}
