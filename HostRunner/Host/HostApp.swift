import SwiftUI

/// A deliberately empty host app. XCUITest requires a UI test target to be
/// attached to some scheme, but this app is never itself under test — every
/// Spec drives the real app under test via `AppUnderTest.launch()`
/// (`XCUIApplication(bundleIdentifier:)`), configured in `config/*.json`.
@main
struct HostApp: App {
    var body: some Scene {
        WindowGroup {
            Text("xcuitest-agentic host runner — not the app under test")
                .padding()
        }
    }
}
