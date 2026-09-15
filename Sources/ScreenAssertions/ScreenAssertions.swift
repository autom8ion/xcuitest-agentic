import XCTest
import XCUITestAgenticCore
import ScreenObject

/// Fluent, polling assertions over a `ScreenElement`. This is the only place
/// `XCTAssert*` should be called from in this framework's tests — Screens
/// never assert, Specs assert only through here.
public struct ScreenElementAssertion {
    let element: ScreenElement
    let file: StaticString
    let line: UInt

    public init(_ element: ScreenElement, file: StaticString = #filePath, line: UInt = #line) {
        self.element = element
        self.file = file
        self.line = line
    }

    @discardableResult
    public func isVisible(timeout: TimeInterval = Waits.defaultTimeout) -> Self {
        let ok = Waits.until(timeout: timeout) { element.exists }
        XCTAssertTrue(ok, "Expected element to become visible within \(timeout)s", file: file, line: line)
        return self
    }

    @discardableResult
    public func isNotVisible(timeout: TimeInterval = Waits.defaultTimeout) -> Self {
        let ok = Waits.until(timeout: timeout) { !element.exists }
        XCTAssertTrue(ok, "Expected element to disappear within \(timeout)s", file: file, line: line)
        return self
    }

    @discardableResult
    public func hasLabel(_ expected: String, timeout: TimeInterval = Waits.defaultTimeout) -> Self {
        let ok = Waits.until(timeout: timeout) { element.exists && element.label == expected }
        XCTAssertTrue(
            ok,
            "Expected label \"\(expected)\", got \"\(element.exists ? element.label : "<missing>")\"",
            file: file,
            line: line
        )
        return self
    }

    /// Checks the element's `value` (e.g. a text field's current entered
    /// text) rather than its `label` — a text field's `label` is its
    /// accessibility label, not its content; use this, not `hasLabel`, to
    /// verify what a user typed.
    @discardableResult
    public func hasValue(_ expected: String, timeout: TimeInterval = Waits.defaultTimeout) -> Self {
        let ok = Waits.until(timeout: timeout) { element.exists && (element.value as? String) == expected }
        let actual = element.exists ? "\(element.value ?? "<nil>")" : "<missing>"
        XCTAssertTrue(ok, "Expected value \"\(expected)\", got \"\(actual)\"", file: file, line: line)
        return self
    }

    @discardableResult
    public func isSelected(timeout: TimeInterval = Waits.defaultTimeout) -> Self {
        let ok = Waits.until(timeout: timeout) { element.exists && element.isSelected }
        XCTAssertTrue(ok, "Expected element to be selected", file: file, line: line)
        return self
    }

    @discardableResult
    public func isNotSelected(timeout: TimeInterval = Waits.defaultTimeout) -> Self {
        let ok = Waits.until(timeout: timeout) { element.exists && !element.isSelected }
        XCTAssertTrue(ok, "Expected element to not be selected", file: file, line: line)
        return self
    }
}

public enum ScreenAssertions {
    public static func assertThat(
        _ element: ScreenElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ScreenElementAssertion {
        ScreenElementAssertion(element, file: file, line: line)
    }
}
