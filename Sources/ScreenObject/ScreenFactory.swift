import XCTest

/// Instantiates a `Screen` subclass bound to the given `XCUIApplication`.
/// Specs call `ScreenFactory.make(LoginScreen.self, app: app)` rather than
/// constructing screens directly, so construction stays uniform if `Screen`
/// ever grows additional required initializer parameters.
public enum ScreenFactory {
    public static func make<T: Screen>(_ type: T.Type, app: XCUIApplication) -> T {
        T.init(app: app)
    }
}
