import XCTest
import ScreenObject

/// The Webview screen (`Webview-screen`) — a URL field and a "Go To Site"
/// button that loads it in an in-app web view. Kept to navigation/presence
/// checks: actually loading a real URL depends on network reachability,
/// which this framework's deterministic core has no business depending on.
public final class WebviewScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["Webview-screen"] } }
    public var urlField: ScreenElement { element { self.screenElement.textFields.firstMatch } }
    public var goToSiteButton: ScreenElement { element { self.app.buttons["Go To Site"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }

    private var screenElement: XCUIElement { app.otherElements["Webview-screen"] }

    public func backToCatalog() { catalogTabItem.tap() }
}
