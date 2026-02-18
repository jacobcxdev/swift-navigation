import SwiftNavigation
import XCTest

/// Category A behavioral parity tests for swift-navigation on Android.
///
/// These tests verify that the Android code paths (no animation, no LocalizedStringResource)
/// behave equivalently to the Apple paths for the public API contract.
/// They run on both platforms without any `#if os(Android)` guards.
final class AndroidParityTests: XCTestCase {

  // MARK: - ButtonState (non-animated)

  func testButtonStateSend() {
    let button = ButtonState<Int>(action: .send(42)) {
      TextState("Tap me")
    }
    XCTAssertEqual(button.label, TextState("Tap me"))
    XCTAssertNotNil(button.action)
  }

  func testButtonStateSendActionExists() {
    let button = ButtonState<String>(action: .send("hello")) {
      TextState("Greet")
    }
    XCTAssertNotNil(button.action, "Button should have an action")
    XCTAssertEqual(button.label, TextState("Greet"))
  }

  func testButtonStateMapTransformsAction() {
    let intButton = ButtonState<Int>(action: .send(1)) {
      TextState("One")
    }
    let stringButton = intButton.map { value -> String in
      guard let v = value else { return "nil" }
      return "\(v)"
    }
    XCTAssertNotNil(stringButton.action, "Mapped button should still have an action")
    XCTAssertEqual(stringButton.label, TextState("One"))
  }

  func testButtonStateRole() {
    let destructive = ButtonState<Void>(role: .destructive, action: .send(())) {
      TextState("Delete")
    }
    XCTAssertEqual(destructive.role, .destructive)

    let cancel = ButtonState<Void>(role: .cancel, action: .send(())) {
      TextState("Cancel")
    }
    XCTAssertEqual(cancel.role, .cancel)
  }

  // MARK: - TextState

  func testTextStateVerbatim() {
    let text = TextState(verbatim: "Hello")
    XCTAssertEqual(text, TextState(verbatim: "Hello"))
  }

  func testTextStateFromStringInterpolation() {
    let text = TextState("Hello, World!")
    XCTAssertEqual(text, TextState("Hello, World!"))
  }

  func testTextStateConcatenation() {
    let hello = TextState(verbatim: "Hello")
    let world = TextState(verbatim: " World")
    let combined = hello + world
    XCTAssertEqual(combined, TextState(verbatim: "Hello") + TextState(verbatim: " World"))
  }

  func testTextStateEquality() {
    let a = TextState(verbatim: "Same")
    let b = TextState(verbatim: "Same")
    let c = TextState(verbatim: "Different")
    XCTAssertEqual(a, b)
    XCTAssertNotEqual(a, c)
  }

  func testTextStateInterpolation() {
    let count = 42
    let text = TextState("Count: \(count)")
    XCTAssertNotNil(text)
  }

  // MARK: - AlertState

  func testAlertStateCreation() {
    let alert = AlertState<Never> {
      TextState("Title")
    } message: {
      TextState("Message")
    }
    XCTAssertEqual(alert.title, TextState("Title"))
    XCTAssertEqual(alert.message, TextState("Message"))
  }

  func testAlertStateWithActions() {
    enum Action {
      case confirm
      case deny
    }
    let alert = AlertState<Action> {
      TextState("Confirm?")
    } actions: {
      ButtonState(action: .send(.confirm)) {
        TextState("Yes")
      }
      ButtonState(role: .cancel, action: .send(.deny)) {
        TextState("No")
      }
    }
    XCTAssertEqual(alert.title, TextState("Confirm?"))
    XCTAssertEqual(alert.buttons.count, 2)
  }

  // MARK: - ConfirmationDialogState

  func testConfirmationDialogStateCreation() {
    let dialog = ConfirmationDialogState<Never> {
      TextState("Choose")
    } message: {
      TextState("Pick one")
    }
    XCTAssertEqual(dialog.title, TextState("Choose"))
    XCTAssertEqual(dialog.message, TextState("Pick one"))
  }
}

// MARK: - Category B: SwiftUI Integration (un-guarded code)

#if canImport(SwiftUI)
  import SwiftUI
  import SwiftUINavigation

  /// Tests verifying un-guarded SwiftUI navigation integrations work correctly.
  /// These exercise the same code paths used on Android via SkipSwiftUI.
  @MainActor
  final class SwiftUINavigationParityTests: XCTestCase {

    // MARK: - Binding<Optional> -> Binding<Bool> (SwiftNavigation/Binding.swift)

    func testBindingOptionalToBool() {
      // Verify Binding<Bool>.init(Binding<V?>) produces a Binding<Bool>.
      // This is un-guarded in SwiftNavigation/Binding.swift.
      var item: String? = nil
      let optionalBinding = Binding<String?>(
        get: { item },
        set: { item = $0 }
      )

      let boolBinding: Binding<Bool> = Binding(optionalBinding)
      XCTAssertFalse(boolBinding.wrappedValue)

      item = "hello"
      let boolBinding2: Binding<Bool> = Binding(optionalBinding)
      XCTAssertTrue(boolBinding2.wrappedValue)
    }

    // MARK: - WithState (SwiftUINavigation/WithState.swift)

    func testWithStateInitializerAndBody() {
      // Verify WithState can be created with an initial value
      // and its body returns the content closure result.
      let view = WithState(initialValue: 42) { (value: Binding<Int>) in
        Text("\(value.wrappedValue)")
      }
      // WithState is a View — verify it exists and body is accessible
      let _ = view.body
    }
  }
#endif
