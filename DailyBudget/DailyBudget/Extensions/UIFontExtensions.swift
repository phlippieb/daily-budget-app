import SwiftUI

extension UIFont {
    static func textStyleSize(
      _ style: UIFont.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: style).pointSize
    }
}

#Preview {
  VStack {
    // Standard large title
    Text("Hello, world!")
      .font(.largeTitle)
    
    // x2
    Text("Hello, world!")
      .font(.system(size: UIFont.textStyleSize(.largeTitle) * 2))
      
    // Larger and scaled down (takes tweaking?)
    Text("Hello, world!")
      .font(.system(size: UIFont.textStyleSize(.largeTitle) * 100))
      .lineLimit(1)
      .minimumScaleFactor(0.02)
    
  }
}
