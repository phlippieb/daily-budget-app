import Foundation

/// Adds `Identifiable` conformance for `Optional`s wrapping `Identifiable` types,
/// where those types are also `UnitProviding`, by returning the id of a unit value when the value is nil.
///
/// # Use case: Double-optional bindings for edit screens
///
/// Consider a view, `EditItemView`, for editing or creating an item. The view can be given an optional
/// item like `var item: Item?` to indicate whether it is editing an existing item (when the optional is
/// non-nil), or creating a new item (when the optional is nil).
///
/// Now consider the use case where the view would like to dismiss itself when editing is complete. This can
/// be achieved by passing a binding of an optional value to the view, which is used by the presenting view
/// as the argument to an `item` argument. The `EditItemView` can dismiss itself by setting this value
/// to nil; however, this requires that the binding is itself *also* optional.
///
/// This gives rise to the following pattern which uses a **double optional**:
///  ```swift
///  struct EditItemView: View {
///    // The outer optional represents whether the edit view is shown.
///    // The inner optional represents the existing item to edit, if any.
///    @Binding var item: Item??
///
///    var body: some View {
///      if let item { ... }
///    }
///
///    func dismiss() {
///      // Setting the binding to nil will dismiss the sheet
///      item = nil
///    }
///  }
///
///  struct ItemView {
///    @State var editingItem: Item??
///
///    var body: some View {
///      ...
///      // Bind the sheet's visibility to the outer optional
///      .sheet(item: $editingItem) {
///        // Pass a binding to the outer optional, which can be set to nil
///        // to dismiss the sheet
///        EditItemView(item: $item)
///      }
///    }
///
///    func editItem(item: Item) {
///      // To edit an existing item, set the inner optional to that item
///      editingItem = item
///    }
///
///    func createItem() {
///      // To create a new item, set the inner optional to nil (but set the
///      // outer optional to some so that the edit sheet is visible).
///      editingItem = .some(nil)
///    }
///  ```
///
/// Using a double optional as an item binding requires that the inner optional must conform to Identifiable.
/// This extension provides this conformance.
extension Optional: Identifiable where Wrapped: Identifiable, Wrapped: UnitProviding {
  public var id: Wrapped.ID {
    return self?.id ?? Wrapped.unit.id
  }
}
