import XCTest
import ScreenAssertions

final class ProductDetailsTests: MyDemoAppUITestCase {
    func testPriceAndHighlightsAreVisible() {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)

        let details = screen(ProductDetailsScreen.self)
        ScreenAssertions.assertThat(details.screenContainer).isVisible()
        ScreenAssertions.assertThat(details.priceLabel).isVisible()
        ScreenAssertions.assertThat(details.productHighlights).isVisible()
    }

    func testIncreasingAndDecreasingAmountUpdatesTheLabel() {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)

        let details = screen(ProductDetailsScreen.self)
        ScreenAssertions.assertThat(details.amountLabel).hasLabel("1")

        details.increaseAmount()
        details.increaseAmount()
        ScreenAssertions.assertThat(details.amountLabel).hasLabel("3")

        details.decreaseAmount()
        ScreenAssertions.assertThat(details.amountLabel).hasLabel("2")
    }

    /// The amount stepper feeds the quantity added to the cart —
    /// verified end to end via the cart's item count, not just the label.
    func testAddingWithIncreasedAmountAddsThatManyItems() {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)

        let details = screen(ProductDetailsScreen.self)
        details.increaseAmount()
        details.increaseAmount()
        ScreenAssertions.assertThat(details.amountLabel).hasLabel("3")
        details.addToCart()
        details.goToCart()

        let cart = screen(CartScreen.self)
        ScreenAssertions.assertThat(cart.itemCountLabel("3 Items")).isVisible()
    }

    func testSelectingAColorDoesNotErrorAndStaysOnScreen() {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)

        let details = screen(ProductDetailsScreen.self)
        details.selectColor(.blue)

        ScreenAssertions.assertThat(details.screenContainer).isVisible()
    }

    func testRatingAProductDoesNotErrorAndStaysOnScreen() {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)

        let details = screen(ProductDetailsScreen.self)
        details.rate(stars: 5)

        ScreenAssertions.assertThat(details.screenContainer).isVisible()
    }
}
