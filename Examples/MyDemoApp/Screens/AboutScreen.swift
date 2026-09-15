import XCTest
import ScreenObject

/// The About screen (`About-screen`), reached from `MoreMenuScreen`.
public final class AboutScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["About-screen"] } }
    public var titleLabel: ScreenElement { element { self.app.staticTexts["About "] } }
    public var goToSaucelabsButton: ScreenElement { element { self.app.buttons["Go to saucelabs.com"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }

    public func backToCatalog() { catalogTabItem.tap() }
}
