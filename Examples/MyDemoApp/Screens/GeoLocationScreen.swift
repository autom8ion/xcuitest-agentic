import XCTest
import ScreenObject

/// The Geo Location screen (`GeoLocation-screen`). Shows fixed demo
/// coordinates (verified live: longitude `13.45143`, latitude `52.50032`)
/// — not device-derived, safe to assert on directly.
public final class GeoLocationScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["GeoLocation-screen"] } }
    public var longitudeValue: ScreenElement { element { self.app.staticTexts["13.45143"] } }
    public var latitudeValue: ScreenElement { element { self.app.staticTexts["52.50032"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }

    public func backToCatalog() { catalogTabItem.tap() }
}
