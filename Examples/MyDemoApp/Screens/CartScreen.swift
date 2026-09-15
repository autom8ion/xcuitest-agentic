import XCTest
import ScreenObject

/// The cart (`Cart-screen`). Line-item controls (verified live) carry only
/// labels, no identifiers, and are shared across every row — `firstMatch`
/// is correct for a single-item cart; a multi-item cart needing a specific
/// row should scope through `app.tables.cells.element(boundBy:)` instead.
public final class CartScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["Cart-screen"] } }
    public var emptyStateLabel: ScreenElement { element { self.app.staticTexts["No Items"] } }
    public var goShoppingButton: ScreenElement { element { self.app.buttons["GoShopping"] } }
    public var proceedToCheckoutButton: ScreenElement { element { self.app.buttons["ProceedToCheckout"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }
    public var removeItemButton: ScreenElement { element { self.app.buttons["Remove Item"].firstMatch } }
    public var increaseQuantityButton: ScreenElement { element { self.app.buttons["AddPlus Icons"].firstMatch } }
    public var decreaseQuantityButton: ScreenElement { element { self.app.buttons["SubtractMinus Icons"].firstMatch } }

    public func itemCountLabel(_ text: String) -> ScreenElement {
        element { self.app.staticTexts[text] }
    }

    public func lineItem(productName: String) -> ScreenElement {
        element { self.app.staticTexts[productName] }
    }

    public func proceedToCheckout() { proceedToCheckoutButton.tap() }
    public func continueShopping() { goShoppingButton.tap() }
    public func removeFirstItem() { removeItemButton.tap() }
    public func increaseFirstItemQuantity() { increaseQuantityButton.tap() }
    public func decreaseFirstItemQuantity() { decreaseQuantityButton.tap() }
}
