import XCTest
import ScreenObject

/// The Drawing screen (`Drawing-screen`) — a signature/sketch canvas with
/// Clear and Save controls. Both carry only labels, no identifiers.
public final class DrawingScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["Drawing-screen"] } }
    public var canvas: ScreenElement { element { self.app.images["DrawingBackground Icons"] } }
    public var clearButton: ScreenElement { element { self.app.buttons["ClearButton Icons"] } }
    public var saveButton: ScreenElement { element { self.app.buttons["SaveButton Icons"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }

    /// Draws a short stroke across the canvas so `clear()` has something
    /// real to remove, rather than clearing an already-blank canvas.
    public func drawStroke() {
        let start = canvas.current.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.2))
        let end = canvas.current.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.8))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    public func clear() { clearButton.tap() }
    public func backToCatalog() { catalogTabItem.tap() }
}
