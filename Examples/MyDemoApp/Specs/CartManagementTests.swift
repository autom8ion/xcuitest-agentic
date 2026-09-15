import XCTest
import ScreenAssertions

final class CartManagementTests: MyDemoAppUITestCase {
    private func addOneItemAndOpenCart() -> CartScreen {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)
        let details = screen(ProductDetailsScreen.self)
        details.addToCart()
        details.goToCart()
        return screen(CartScreen.self)
    }

    /// Removing the cart's only item switches straight to the "No Items"
    /// empty state on the same screen instance — verified live; an earlier
    /// version of this test assumed (from a source-only reading of
    /// `MyCartViewController`) that the empty state only re-evaluates in
    /// `viewDidLoad` and so wouldn't appear until a fresh visit. That
    /// reading was wrong: live, the total/"N Items" bar disappears
    /// entirely and "No Items" shows immediately once the cart is empty —
    /// there's no bottom total bar to assert on anymore at that point.
    func testRemovingTheOnlyItemShowsTheEmptyStateImmediately() {
        let cart = addOneItemAndOpenCart()
        ScreenAssertions.assertThat(cart.itemCountLabel("1 Items")).isVisible()

        cart.removeFirstItem()
        ScreenAssertions.assertThat(cart.emptyStateLabel).isVisible()

        // And it's not just this screen instance — a fresh visit agrees.
        cart.catalogTabItem.tap()
        let catalog = screen(CatalogScreen.self)
        catalog.goToCart()
        ScreenAssertions.assertThat(screen(CartScreen.self).emptyStateLabel).isVisible()
    }

    func testIncreasingQuantityInCartUpdatesTheTotal() {
        let cart = addOneItemAndOpenCart()
        ScreenAssertions.assertThat(cart.itemCountLabel("1 Items")).isVisible()

        cart.increaseFirstItemQuantity()
        ScreenAssertions.assertThat(cart.itemCountLabel("2 Items")).isVisible()
    }

    func testDecreasingQuantityInCartUpdatesTheTotal() {
        let cart = addOneItemAndOpenCart()
        cart.increaseFirstItemQuantity()
        ScreenAssertions.assertThat(cart.itemCountLabel("2 Items")).isVisible()

        cart.decreaseFirstItemQuantity()
        ScreenAssertions.assertThat(cart.itemCountLabel("1 Items")).isVisible()
    }
}
