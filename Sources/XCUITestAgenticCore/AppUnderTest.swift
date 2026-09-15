import XCTest

/// Launches the configured app under test by bundle identifier. Specs and
/// Screens never construct `XCUIApplication()` directly — they go through
/// here, so which app gets driven stays entirely a `TestEnvironment` config
/// concern.
public enum AppUnderTest {
    /// Xcode automatically appends this to an app's launch arguments — but
    /// only when that app is configured as the UI test target's own "Target
    /// Application." Since this framework instead drives an external app by
    /// bundle identifier (so it can be pointed at any app via config), we
    /// have to add it ourselves. Without it, an app using UIKit scene state
    /// restoration resumes on whatever screen it last showed instead of
    /// cold-starting — verified against saucelabs/my-demo-app-ios, which
    /// otherwise resumed mid-navigation instead of on the login screen.
    private static let disableStateRestorationArguments = ["-ApplePersistenceIgnoreState", "YES"]

    @discardableResult
    public static func launch(config: AppTargetConfig = TestEnvironment.load()) -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: config.bundleIdentifier)
        app.launchArguments = disableStateRestorationArguments + config.launchArguments
        app.launchEnvironment = config.launchEnvironment
        app.launch()
        return app
    }
}
