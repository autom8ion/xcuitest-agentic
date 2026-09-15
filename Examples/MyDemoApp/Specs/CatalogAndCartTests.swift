import XCTest
import ScreenAssertions

final class CatalogAndCartTests: MyDemoAppUITestCase {
    func testAddSingleItemToCart() {
        let catalog = screen(CatalogScreen.self)
        ScreenAssertions.assertThat(catalog.screenContainer).isVisible()
        catalog.openProduct(atIndex: 0)

        let details = screen(ProductDetailsScreen.self)
        ScreenAssertions.assertThat(details.screenContainer).isVisible()
        details.addToCart()
        details.goToCart()

        let cart = screen(CartScreen.self)
        ScreenAssertions.assertThat(cart.screenContainer).isVisible()
        ScreenAssertions.assertThat(cart.itemCountLabel("1 Items")).isVisible()
    }

    func testAddMultipleItemsToCart() {
        let catalog = screen(CatalogScreen.self)
        let details = screen(ProductDetailsScreen.self)

        for index in 0..<3 {
            catalog.openProduct(atIndex: index)
            ScreenAssertions.assertThat(details.screenContainer).isVisible()
            details.addToCart()
            details.backToCatalog()
        }

        catalog.goToCart()
        let cart = screen(CartScreen.self)
        ScreenAssertions.assertThat(cart.itemCountLabel("3 Items")).isVisible()
    }

    func testEmptyCartShowsGoShoppingState() {
        let catalog = screen(CatalogScreen.self)
        catalog.goToCart()

        let cart = screen(CartScreen.self)
        ScreenAssertions.assertThat(cart.emptyStateLabel).isVisible()
        ScreenAssertions.assertThat(cart.goShoppingButton).isVisible()
    }
}
