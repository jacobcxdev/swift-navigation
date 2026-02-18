#if canImport(SwiftUI) && !os(Android)
  import SwiftUI

  extension Binding where Value: Sendable {
    func didSet(_ perform: @escaping @Sendable (Value) -> Void) -> Self {
      #if os(Android)
        .init(
          get: { self.wrappedValue },
          set: { newValue in
            self.wrappedValue = newValue
            perform(newValue)
          }
        )
      #else
        .init(
          get: { self.wrappedValue },
          set: { newValue, transaction in
            self.transaction(transaction).wrappedValue = newValue
            perform(newValue)
          }
        )
      #endif
    }
  }
#endif  // canImport(SwiftUI) && !os(Android)
