import XCTest

/// Base class for every screen object. Holds only a reference to the live
/// `XCUIApplication` — never a cached `XCUIElement` — so every element
/// declared by a subclass re-resolves against the current UI tree. See
/// `ScreenElement`.
///
/// Subclasses should expose only:
///  1. Element getters (computed properties returning `ScreenElement`/`ScreenElementList`)
///  2. Action methods (`func tapAddToCart()`, one per user intent)
/// Assertions belong in a Spec via `ScreenAssertions`, never inline here.
open class Screen {
    public let app: XCUIApplication

    public required init(app: XCUIApplication) {
        self.app = app
    }

    /// Wraps a query closure as a re-resolving `ScreenElement`.
    public func element(_ query: @escaping () -> XCUIElement) -> ScreenElement {
        ScreenElement(resolve: query)
    }

    /// Wraps a query closure as a re-resolving `ScreenElementList`.
    public func elements(_ query: @escaping () -> XCUIElementQuery) -> ScreenElementList {
        ScreenElementList(resolve: query)
    }

    /// Attempts to dismiss the on-screen keyboard by swiping down on it, if
    /// one is showing.
    ///
    /// This is a best-effort convenience for apps that opt into
    /// `UIScrollView`'s interactive keyboard dismissal — it is **not** a
    /// universal iOS mechanism. Verified live against
    /// `saucelabs/my-demo-app-ios`'s login form that it does **not** help
    /// there: that app has no tap-to-dismiss gesture, no return-key
    /// handling, and no keyboard-avoidance layout anywhere, and a swipe on
    /// the keyboard (an iPad-only "undock" gesture, not a thing on iPhone)
    /// does nothing either. If a submit button below a form's last field
    /// sits low enough to be covered once the keyboard appears, calling
    /// this first is worth trying, but confirm live rather than assuming it
    /// resolved the problem — see `LoginScreen`'s doc comment for the full
    /// account of what was actually tried and what the real workaround was
    /// (the app's own quick-login buttons, which never raise the keyboard).
    public func dismissKeyboardIfPresent() {
        let keyboard = app.keyboards.element
        if keyboard.exists {
            keyboard.swipeDown()
        }
    }
}
