import XCTest
import ScreenObject

/// The order-confirmation screen (`CheckoutComplete-screen`).
public final class CheckoutCompleteScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["CheckoutComplete-screen"] } }
    public var continueShoppingButton: ScreenElement { element { self.app.buttons["ContinueShopping"] } }

    public func continueShopping() { continueShoppingButton.tap() }
}
