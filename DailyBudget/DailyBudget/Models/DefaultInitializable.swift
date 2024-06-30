public protocol DefaultInitializable {
  init()
}

public protocol UnitProvider {
  static var unit: Self { get }
}
