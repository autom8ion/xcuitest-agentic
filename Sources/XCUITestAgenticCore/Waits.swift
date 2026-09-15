import XCTest

/// The framework's one wait/poll primitive. Screens, `ScreenElement`, and
/// `ScreenAssertions` are all built on this — nothing in the framework calls
/// `sleep()` or `Thread.sleep`, and nothing should.
public enum Waits {
    public static let defaultTimeout: TimeInterval = 10
    public static let pollInterval: TimeInterval = 0.2

    /// Polls `condition` until it returns true or `timeout` elapses.
    @discardableResult
    public static func until(
        timeout: TimeInterval = Waits.defaultTimeout,
        pollInterval: TimeInterval = Waits.pollInterval,
        _ condition: @escaping () -> Bool
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(pollInterval))
        }
        return condition()
    }

    /// Waits for `element` to exist and returns it, failing the calling test
    /// (via `file`/`line`) if it never appears.
    @discardableResult
    public static func expectExistence(
        of element: XCUIElement,
        timeout: TimeInterval = Waits.defaultTimeout,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        guard element.waitForExistence(timeout: timeout) else {
            XCTFail("Expected element to exist within \(timeout)s: \(element)", file: file, line: line)
            return element
        }
        return element
    }
}
