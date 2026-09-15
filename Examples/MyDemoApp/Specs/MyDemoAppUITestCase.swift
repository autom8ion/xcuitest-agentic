import XCTest
import XCUITestAgenticCore
import ScreenObject
import ScreenAssertions

/// Shared setup for every My Demo App spec: launches the configured app
/// under test fresh for each test and always starts in portrait, matching
/// the app's own `MyDemoAppUITests/utils/MyDemoAppTestBase.swift`.
class MyDemoAppUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = AppUnderTest.launch()
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    func screen<T: Screen>(_ type: T.Type) -> T {
        ScreenFactory.make(type, app: app)
    }
}
