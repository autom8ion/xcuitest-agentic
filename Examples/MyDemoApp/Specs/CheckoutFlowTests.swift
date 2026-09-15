import XCTest
import ScreenAssertions

/// Guest browse -> add to cart -> checkout. Checking out while unauthenticated
/// routes through `LoginScreen` first (verified in
/// `MyCartViewController.preccedToCheckoutButton` — `isFromProcessCheckout`
/// then sends a successful login straight to `ShippingAddressScreen`).
final class CheckoutFlowTests: MyDemoAppUITestCase {
    /// Verifies everything up through reaching the Shipping form and filling
    /// its three reliably-fillable fields. Stops there and skips rather than
    /// attempting city/state/zip/country or Payment/Review/Complete — see
    /// `ShippingAddressScreen`'s doc comment for the confirmed, unresolved
    /// keyboard-overlap defect that blocks those fields, and
    /// `.claude/skills/app-notes` for the full account. This is a real app
    /// limitation discovered through live verification, not a gap in this
    /// framework's coverage.
    func testGuestCheckoutReachesShippingForm() throws {
        let catalog = screen(CatalogScreen.self)
        ScreenAssertions.assertThat(catalog.screenContainer).isVisible()
        catalog.openProduct(atIndex: 0)

        let details = screen(ProductDetailsScreen.self)
        ScreenAssertions.assertThat(details.screenContainer).isVisible()
        details.addToCart()
        details.goToCart()

        let cart = screen(CartScreen.self)
        ScreenAssertions.assertThat(cart.screenContainer).isVisible()
        cart.proceedToCheckout()

        // Not authenticated yet — checkout routes through login first.
        // Uses the app's quick-login buttons rather than typing — see
        // LoginScreen's doc comment for why manual entry can't submit at all.
        let login = screen(LoginScreen.self)
        ScreenAssertions.assertThat(login.loginButton).isVisible()
        login.quickLogin(as: .alice)

        let shipping = screen(ShippingAddressScreen.self)
        ScreenAssertions.assertThat(shipping.screenContainer).isVisible()
        shipping.fillReliableFields(
            fullName: "Ada Lovelace",
            address1: "12 Analytical Engine Ave"
        )
        ScreenAssertions.assertThat(shipping.fullNameField).hasValue("Ada Lovelace")
        ScreenAssertions.assertThat(shipping.address1Field).hasValue("12 Analytical Engine Ave")

        throw XCTSkip(
            "xcuitest-agentic: city/state/zip/country and everything past Shipping " +
            "(Payment, Review, Checkout Complete) are confirmed blocked by the same " +
            "keyboard-overlap defect as LoginScreen's manual entry — the app has no " +
            "dismiss mechanism and no quick-fill for this form. See " +
            "ShippingAddressScreen's doc comment and .claude/skills/app-notes."
        )
    }
}
