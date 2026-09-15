import XCTest
import XCUITestAgenticCore

/// A lazily and repeatedly re-resolving wrapper around an `XCUIElement`.
///
/// This is the framework's sole defense against the XCUITest analog of a
/// stale-element failure: a Screen never stores a resolved `XCUIElement` in
/// a field. Every `tap()`, `typeText()`, or `exists` check re-runs the
/// underlying query against the live accessibility tree, so a view reload
/// between two lines of a test never leaves you holding a dead reference.
public struct ScreenElement {
    private let resolve: () -> XCUIElement

    public init(resolve: @escaping () -> XCUIElement) {
        self.resolve = resolve
    }

    /// The freshly re-resolved element. Prefer the action/query members
    /// below over reaching for this directly.
    public var current: XCUIElement { resolve() }

    public var exists: Bool { resolve().exists }

    public var label: String { resolve().label }

    public var value: Any? { resolve().value }

    public var isSelected: Bool { resolve().isSelected }

    @discardableResult
    public func waitForExistence(timeout: TimeInterval = Waits.defaultTimeout) -> XCUIElement {
        Waits.expectExistence(of: resolve(), timeout: timeout)
    }

    public func tap(timeout: TimeInterval = Waits.defaultTimeout) {
        waitForExistence(timeout: timeout).tap()
    }

    public func typeText(_ text: String, timeout: TimeInterval = Waits.defaultTimeout) {
        let el = waitForExistence(timeout: timeout)
        el.tap()
        el.typeText(text)
    }

    /// Taps, deletes any existing value character-by-character, then types
    /// `text`. Use this for fields a flow might revisit (e.g. re-running a
    /// shipping form), where a fresh `typeText` alone would append.
    public func clearAndTypeText(_ text: String, timeout: TimeInterval = Waits.defaultTimeout) {
        let el = waitForExistence(timeout: timeout)
        el.tap()
        if let currentValue = el.value as? String, !currentValue.isEmpty {
            let deleteString = String(repeating: "\u{8}", count: currentValue.count)
            el.typeText(deleteString)
        }
        el.typeText(text)
    }
}
