import XCTest
import ScreenObject

/// The final order-review step before placing the order. This screen's
/// container has no `accessibilityIdentifier` in the app's storyboard, so
/// presence is anchored on the "Place Order" button instead.
public final class ReviewOrderScreen: Screen {
    public var placeOrderButton: ScreenElement { element { self.app.buttons["Place Order"] } }

    public func placeOrder() { placeOrderButton.tap() }
}
