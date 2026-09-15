import XCTest
import ScreenObject

/// The payment form (`Payment-screen`). The "billing address same as
/// shipping" toggle defaults to selected (verified in
/// `PaymentMethodViewController.viewDidLoad`), so the billing-address
/// sub-form stays hidden and out of the accessibility tree — the four
/// indexed text fields below are unambiguously the card fields, not a guess
/// that happens to work. See `ShippingAddressScreen` for why these fields
/// are indexed rather than identifier-based.
public final class PaymentScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["Payment-screen"] } }
    public var reviewOrderButton: ScreenElement { element { self.app.buttons["Review Order"] } }

    private func field(_ index: Int) -> ScreenElement {
        element { self.app.otherElements["Payment-screen"].textFields.element(boundBy: index) }
    }

    public var fullNameOnCardField: ScreenElement { field(0) }
    public var cardNumberField: ScreenElement { field(1) }
    public var expirationDateField: ScreenElement { field(2) }
    public var securityCodeField: ScreenElement { field(3) }

    public func fillCardDetails(
        fullNameOnCard: String,
        cardNumber: String,
        expirationDate: String,
        securityCode: String
    ) {
        fullNameOnCardField.typeText(fullNameOnCard)
        cardNumberField.typeText(cardNumber)
        expirationDateField.typeText(expirationDate)
        securityCodeField.typeText(securityCode)
    }

    /// Dismisses the keyboard before tapping — see
    /// `ShippingAddressScreen.proceedToPayment` / `Screen.dismissKeyboardIfPresent`.
    public func proceedToReview() {
        dismissKeyboardIfPresent()
        reviewOrderButton.tap()
    }
}
